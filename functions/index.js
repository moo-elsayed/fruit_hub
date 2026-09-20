const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// ── Collection / Document paths for Analytics ──────────────────────────────
const ORDERS_COLLECTION = "orders";
const ANALYTICS_COLLECTION = "analytics";
const SUMMARY_DOC = "summary";
const DAILY_COLLECTION = "analytics_daily";

// ── Analytics Helpers ───────────────────────────────────────────────────────

/**
 * Extracts YYYY-MM-DD string from the order's `date` field.
 * Falls back to today if invalid.
 */
function extractDateKey(dateStr) {
  try {
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) throw new Error("invalid");
    return d.toISOString().split("T")[0]; // "2026-09-14"
  } catch (_) {
    return new Date().toISOString().split("T")[0];
  }
}

/**
 * Returns the Firestore status key for a given status string.
 * Maps to the field names stored in analytics/summary.
 */
function statusToField(status) {
  const map = {
    pending: "pendingOrders",
    processing: "processingOrders",
    shipped: "shippedOrders",
    delivered: "deliveredOrders",
    cancelled: "cancelledOrders",
  };
  return map[(status || "").toLowerCase().trim()] ?? "pendingOrders";
}

/**
 * Returns the Firestore payment method key for a given paymentMethod string.
 * Maps to fields in analytics/summary.paymentMethods.
 */
function paymentMethodToField(method) {
  const map = {
    paypal: "paypal",
    credit_card: "credit_card",
    card: "credit_card",
    cash_on_delivery: "cash_on_delivery",
    cash: "cash_on_delivery",
  };
  return map[(method || "").toLowerCase().trim()] ?? "cash_on_delivery";
}

/**
 * Applies delta updates to analytics/summary and analytics/daily for an order.
 * @param {FirebaseFirestore.WriteBatch} batch
 * @param {object} order - plain order data
 * @param {number} sign - +1 for addition, -1 for deletion
 */
function applyOrderAnalyticsDelta(batch, order, sign) {
  const totalPrice = Number(order.totalPrice ?? 0) * sign;
  const statusField = statusToField(order.status);
  const paymentField = paymentMethodToField(order.paymentMethod);
  const dateKey = extractDateKey(order.date);
  const items = Array.isArray(order.orderItems) ? order.orderItems : [];

  // 1. Update analytics/summary
  const summaryRef = db.collection(ANALYTICS_COLLECTION).doc(SUMMARY_DOC);
  batch.set(
    summaryRef,
    {
      totalRevenue: FieldValue.increment(totalPrice),
      totalOrders: FieldValue.increment(sign),
      [statusField]: FieldValue.increment(sign),
      paymentMethods: {
        [paymentField]: FieldValue.increment(sign),
      },
    },
    { merge: true }
  );

  // 2. Update analytics_daily/{dateKey} with embedded product statistics
  const dailyRef = db.collection(DAILY_COLLECTION).doc(dateKey);

  const dailyUpdate = {
    date: dateKey,
    revenue: FieldValue.increment(totalPrice),
    ordersCount: FieldValue.increment(sign),
    [`orderStatuses.${statusField}`]: FieldValue.increment(sign),
    [`paymentMethods.${paymentField}`]: FieldValue.increment(sign),
  };

  for (const item of items) {
    const code = item.code || item.fruitCode || item.productId || "";
    if (!code) continue;

    const itemPrice = Number(item.price ?? 0);
    const itemQty = Number(item.quantity ?? 1) * sign;
    const itemRevenue = itemPrice * Number(item.quantity ?? 1) * sign;

    dailyUpdate[`products.${code}.code`] = String(code);
    dailyUpdate[`products.${code}.name`] = item.name || "";
    dailyUpdate[`products.${code}.imagePath`] =
      item.imageUrl || item.imagePath || "";
    dailyUpdate[`products.${code}.quantitySold`] =
      FieldValue.increment(itemQty);
    dailyUpdate[`products.${code}.revenue`] =
      FieldValue.increment(itemRevenue);
  }

  batch.set(dailyRef, dailyUpdate, { merge: true });
}

// ═══════════════════════════════════════════════════════════════════════════
// 0. Order Created: Update Product Selling Counts + Analytics Aggregation
// ═══════════════════════════════════════════════════════════════════════════
exports.onOrderCreated = onDocumentCreated(
  "orders/{orderDocId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const orderData = snapshot.data();
    if (!orderData) return;

    const status = (orderData.status || "").toLowerCase().trim();
    const orderItems = orderData.orderItems || [];
    const orderDocId = event.params.orderDocId;

    const batch = db.batch();

    // A. Selling Count update (Fruit Hub core feature)
    if (status !== "cancelled" && Array.isArray(orderItems) && orderItems.length > 0) {
      for (const item of orderItems) {
        const productCode = item.code || item.fruitCode || item.productId;
        const qty = Number(item.quantity) || 1;
        if (!productCode || qty <= 0) continue;

        const productRef = db.collection("products").doc(String(productCode));
        batch.set(
          productRef,
          { sellingCount: FieldValue.increment(qty) },
          { merge: true }
        );
      }
      batch.update(snapshot.ref, { sellingCountApplied: true });
    }

    // B. Analytics Aggregation (Dashboard core feature)
    applyOrderAnalyticsDelta(batch, orderData, +1);

    try {
      await batch.commit();
      logger.info(
        `Successfully processed onOrderCreated for order ${orderDocId} (Selling Counts + Analytics).`
      );
    } catch (error) {
      logger.error(
        `Failed to process onOrderCreated for order ${orderDocId}:`,
        error
      );
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 1. Order Status Changed Notification + Status/Price Analytics Sync
// ═══════════════════════════════════════════════════════════════════════════
exports.onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderDocId}",
  async (event) => {
    const beforeData = event.data?.before?.data();
    const afterData = event.data?.after?.data();

    if (!beforeData || !afterData) return;

    const oldStatus = (beforeData.status || "").toLowerCase().trim();
    const newStatus = (afterData.status || "").toLowerCase().trim();
    const statusChanged = oldStatus !== newStatus;
    const priceChanged = Number(beforeData.totalPrice) !== Number(afterData.totalPrice);

    const orderId =
      afterData.orderId != null ? afterData.orderId : event.params.orderDocId;
    const userId = afterData.uId || afterData.userId;

    // ── 1. Analytics Sync on Status / Price Changes ────────────────────────
    if (statusChanged || priceChanged) {
      const analyticsBatch = db.batch();
      const summaryRef = db.collection(ANALYTICS_COLLECTION).doc(SUMMARY_DOC);

      if (statusChanged) {
        const oldField = statusToField(oldStatus);
        const newField = statusToField(newStatus);
        analyticsBatch.set(
          summaryRef,
          {
            [oldField]: FieldValue.increment(-1),
            [newField]: FieldValue.increment(+1),
          },
          { merge: true }
        );
      }

      if (priceChanged) {
        const revenueDelta =
          Number(afterData.totalPrice ?? 0) - Number(beforeData.totalPrice ?? 0);
        const dateKey = extractDateKey(afterData.date || beforeData.date);
        const dailyRef = db.collection(DAILY_COLLECTION).doc(dateKey);

        analyticsBatch.set(
          summaryRef,
          { totalRevenue: FieldValue.increment(revenueDelta) },
          { merge: true }
        );
        analyticsBatch.set(
          dailyRef,
          { revenue: FieldValue.increment(revenueDelta) },
          { merge: true }
        );
      }

      try {
        await analyticsBatch.commit();
        logger.info(`Updated analytics for order ${orderId} status/price change.`);
      } catch (err) {
        logger.error(`Failed to update analytics on status change for ${orderId}:`, err);
      }
    }

    // If status didn't change, we don't need notifications or sellingCount rollback
    if (!newStatus || !statusChanged) return;

    // ── 2. Handle sellingCount rollback on cancellation or re-apply ─────────
    if (newStatus === "cancelled" && beforeData.sellingCountApplied === true) {
      try {
        await adjustProductSellingCounts(
          afterData.orderItems || beforeData.orderItems || [],
          -1,
          event.data.after.ref,
          false,
          orderId
        );
        logger.info(`Rolled back sellingCount for cancelled order ${orderId}`);
      } catch (err) {
        logger.error(`Failed to rollback sellingCount for order ${orderId}:`, err);
      }
    } else if (
      oldStatus === "cancelled" &&
      newStatus !== "cancelled" &&
      beforeData.sellingCountApplied === false
    ) {
      try {
        await adjustProductSellingCounts(
          afterData.orderItems || beforeData.orderItems || [],
          1,
          event.data.after.ref,
          true,
          orderId
        );
        logger.info(`Re-applied sellingCount for un-cancelled order ${orderId}`);
      } catch (err) {
        logger.error(`Failed to re-apply sellingCount for order ${orderId}:`, err);
      }
    }

    if (!userId) {
      logger.warn(`Order ${orderId} has no userId/uId associated.`);
      return;
    }

    // ── 3. Fetch user details & send localized push notifications ──────────
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      logger.warn(`User document not found for user: ${userId}`);
      return;
    }

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;
    const isArabic = (userData.languageCode || "ar") === "ar";

    const arContent = getOrderStatusMessage(newStatus, orderId, true);
    const enContent = getOrderStatusMessage(newStatus, orderId, false);
    if (!arContent || !enContent) return;

    const { title, body } = isArabic ? arContent : enContent;

    if (fcmToken) {
      try {
        await messaging.send({
          token: fcmToken,
          notification: { title, body },
          data: {
            type: "order",
            orderId: String(orderId),
            status: String(newStatus),
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "fruit_hub_notifications",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: { sound: "default", badge: 1 },
            },
          },
        });
        logger.info(
          `Push notification sent to user ${userId} for order ${orderId} status: ${newStatus}`
        );
      } catch (error) {
        logger.error(
          `Failed to send push notification to user ${userId}:`,
          error
        );
        await handleFcmError(error, userId);
      }
    }

    try {
      await db.collection("users").doc(userId).collection("notifications").add({
        titleAr: arContent.title,
        titleEn: enContent.title,
        bodyAr: arContent.body,
        bodyEn: enContent.body,
        type: "order",
        orderId: String(orderId),
        status: String(newStatus),
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    } catch (error) {
      logger.error(
        `Failed to save notification record for user ${userId}:`,
        error
      );
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 2. Post-Delivery Review Prompt Notification
// ═══════════════════════════════════════════════════════════════════════════
exports.onOrderDeliveredPromptReview = onDocumentUpdated(
  "orders/{orderDocId}",
  async (event) => {
    const beforeData = event.data?.before?.data();
    const afterData = event.data?.after?.data();

    if (!beforeData || !afterData) return;

    const beforeStatus = (beforeData.status || "").toLowerCase().trim();
    const afterStatus = (afterData.status || "").toLowerCase().trim();

    if (beforeStatus === "delivered" || afterStatus !== "delivered") {
      return;
    }

    const userId = afterData.uId || afterData.userId;
    const orderItems = afterData.orderItems || [];

    if (!userId || orderItems.length === 0) return;

    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;
    const isArabic = (userData.languageCode || "ar") === "ar";

    for (const item of orderItems) {
      const productCode = item.code || item.fruitCode || item.productId;
      if (!productCode) continue;

      const productDoc = await db
        .collection("products")
        .doc(String(productCode))
        .get();
      if (!productDoc.exists) continue;

      const productData = productDoc.data() || {};
      const reviews = productData.reviews || [];

      const hasAlreadyReviewed = reviews.some(
        (r) =>
          (r.userId && r.userId === userId) || (r.uId && r.uId === userId)
      );

      if (hasAlreadyReviewed) {
        logger.info(
          `User ${userId} already reviewed product ${productCode}. Skipping prompt.`
        );
        continue;
      }

      const productNameAr = item.name || "المنتج";
      const productNameEn = item.name || "the product";

      const titleAr = "كيف كانت الفواكه؟ ⭐";
      const titleEn = "How was your fruit? ⭐";
      const bodyAr = `شاركنا رأيك في "${productNameAr}" وساعد عملاء آخرين في اختيار الأفضل!`;
      const bodyEn = `Share your review for "${productNameEn}" to help other buyers!`;

      const pushTitle = isArabic ? titleAr : titleEn;
      const pushBody = isArabic ? bodyAr : bodyEn;

      if (fcmToken) {
        try {
          await messaging.send({
            token: fcmToken,
            notification: { title: pushTitle, body: pushBody },
            data: {
              type: "review",
              productCode: String(productCode),
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "fruit_hub_notifications",
                sound: "default",
              },
            },
          });
          logger.info(
            `Review prompt sent to user ${userId} for product ${productCode}`
          );
        } catch (error) {
          logger.error(
            `Failed to send review prompt to user ${userId}:`,
            error
          );
          await handleFcmError(error, userId);
        }
      }

      await db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .add({
          titleAr,
          titleEn,
          bodyAr,
          bodyEn,
          type: "review",
          productCode: String(productCode),
          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
        });

      break;
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 3. Abandoned Cart Reminder Notification (Scheduled)
// ═══════════════════════════════════════════════════════════════════════════
exports.checkAbandonedCarts = onSchedule(
  {
    schedule: "0 18 * * *",
    timeZone: "UTC",
  },
  async (event) => {
    logger.info("Running checkAbandonedCarts scheduled job...");

    const usersSnapshot = await db
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const now = Date.now();
    const TWO_DAYS_MS = 48 * 60 * 60 * 1000;

    const candidates = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data() || {};
      const cartItems = userData.cartItems || [];
      const fcmToken = userData.fcmToken;

      if (!Array.isArray(cartItems) || cartItems.length === 0 || !fcmToken) {
        continue;
      }

      const lastReminder = userData.lastCartReminderSentAt?.toMillis?.() || 0;
      if (now - lastReminder < TWO_DAYS_MS) {
        continue;
      }

      candidates.push({ userDoc, userData, fcmToken });
    }

    logger.info(
      `Found ${candidates.length} candidate users for abandoned cart reminders.`
    );

    const chunkSize = 20;
    for (let i = 0; i < candidates.length; i += chunkSize) {
      const chunk = candidates.slice(i, i + chunkSize);
      await Promise.allSettled(
        chunk.map(async ({ userDoc, userData, fcmToken }) => {
          const isArabic = (userData.languageCode || "ar") === "ar";
          const titleAr = "سلتك في انتظارك! 🛒";
          const titleEn = "Your cart is waiting! 🛒";
          const bodyAr =
            "فواكهك المفضلة لا تزال في السلة، أكمل طلبك الآن لتصلك طازجة!";
          const bodyEn =
            "Your favorite fresh fruits are still in your cart. Complete your order now!";

          const pushTitle = isArabic ? titleAr : titleEn;
          const pushBody = isArabic ? bodyAr : bodyEn;

          try {
            await messaging.send({
              token: fcmToken,
              notification: { title: pushTitle, body: pushBody },
              data: {
                type: "cart",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
              android: {
                priority: "high",
                notification: {
                  channelId: "fruit_hub_notifications",
                  sound: "default",
                },
              },
            });

            const batch = db.batch();
            const notificationRef = db
              .collection("users")
              .doc(userDoc.id)
              .collection("notifications")
              .doc();

            batch.set(notificationRef, {
              titleAr,
              titleEn,
              bodyAr,
              bodyEn,
              type: "cart",
              isRead: false,
              createdAt: FieldValue.serverTimestamp(),
            });

            batch.update(userDoc.ref, {
              lastCartReminderSentAt: FieldValue.serverTimestamp(),
            });

            await batch.commit();
            logger.info(`Abandoned cart reminder sent to user: ${userDoc.id}`);
          } catch (error) {
            logger.error(
              `Error sending abandoned cart notification to ${userDoc.id}:`,
              error
            );
            await handleFcmError(error, userDoc.id);
          }
        })
      );
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 4. Admin Dashboard Direct Notification Trigger
// ═══════════════════════════════════════════════════════════════════════════
exports.onAdminNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationDocId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const notificationData = snapshot.data();
    if (!notificationData) return;

    if (
      notificationData.source !== "admin_dashboard" ||
      notificationData.pushSent === true
    ) {
      return;
    }

    const { userId, notificationDocId } = event.params;
    if (!userId) {
      logger.warn(`Notification ${notificationDocId} has no associated userId.`);
      return;
    }

    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      logger.warn(`User document not found for user: ${userId}`);
      return;
    }

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      logger.info(
        `User ${userId} has no fcmToken registered. In-app notification preserved.`
      );
      await snapshot.ref.update({ pushSent: false, pushStatus: "no_fcm_token" });
      return;
    }

    const isArabic = (userData.languageCode || "ar") === "ar";

    const pushTitle = isArabic
      ? (notificationData.titleAr || notificationData.title || "إشعار جديد 🔔")
      : (notificationData.titleEn || notificationData.title || "New Notification 🔔");

    const pushBody = isArabic
      ? (notificationData.bodyAr || notificationData.body || "")
      : (notificationData.bodyEn || notificationData.body || "");

    try {
      await messaging.send({
        token: fcmToken,
        notification: {
          title: pushTitle,
          body: pushBody,
        },
        data: {
          type: String(notificationData.type || "general"),
          notificationId: String(notificationDocId),
          source: "admin_dashboard",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "fruit_hub_notifications",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: { sound: "default", badge: 1 },
          },
        },
      });

      await snapshot.ref.update({ pushSent: true, pushStatus: "delivered" });

      logger.info(
        `Admin push notification sent successfully to user ${userId} for notification ${notificationDocId}`
      );
    } catch (error) {
      logger.error(
        `Failed to send admin push notification to user ${userId}:`,
        error
      );
      await handleFcmError(error, userId);
      await snapshot.ref.update({ pushSent: false, pushStatus: "failed" });
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 5. Shipping Configuration Updated: Broadcast Notification
// ═══════════════════════════════════════════════════════════════════════════
exports.onShippingConfigUpdated = onDocumentUpdated(
  "constants/shipping_config",
  async (event) => {
    const change = event.data;
    if (!change) return;

    const afterData = change.after.data();
    if (!afterData) return;

    const broadcast = afterData.broadcast_notification;
    if (!broadcast || broadcast.notify !== true) {
      return;
    }

    if (broadcast.processed === true) {
      return;
    }

    const titleAr = broadcast.titleAr || "تحديث مصاريف الشحن 🚚";
    const titleEn = broadcast.titleEn || "Shipping Fees Updated 🚚";
    const bodyAr = broadcast.bodyAr || "";
    const bodyEn = broadcast.bodyEn || "";
    const type = broadcast.type || "general";

    logger.info("Starting broadcast notification for shipping config update...");

    await change.after.ref.update({
      "broadcast_notification.notify": false,
      "broadcast_notification.processed": true,
      "broadcast_notification.processedAt": FieldValue.serverTimestamp(),
    });

    try {
      const usersSnapshot = await db.collection("users").get();
      if (usersSnapshot.empty) {
        logger.info("No users found to notify.");
        return;
      }

      logger.info(`Notifying ${usersSnapshot.size} users about shipping update...`);

      const BATCH_SIZE = 400;
      let currentBatch = db.batch();
      let writeCount = 0;
      const fcmPromises = [];

      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data() || {};
        const fcmToken = userData.fcmToken;
        const isArabic = (userData.languageCode || "ar") === "ar";

        if (fcmToken) {
          const pushTitle = isArabic ? titleAr : titleEn;
          const pushBody = isArabic ? bodyAr : bodyEn;

          fcmPromises.push(
            messaging
              .send({
                token: fcmToken,
                notification: {
                  title: pushTitle,
                  body: pushBody,
                },
                data: {
                  type: type,
                  source: "shipping_update",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                android: {
                  priority: "high",
                  notification: {
                    channelId: "fruit_hub_notifications",
                    sound: "default",
                  },
                },
                apns: {
                  payload: {
                    aps: { sound: "default", badge: 1 },
                  },
                },
              })
              .catch((err) => {
                logger.warn(`Failed to send FCM to user ${userDoc.id}:`, err);
              })
          );
        }

        const notifRef = db
          .collection("users")
          .doc(userDoc.id)
          .collection("notifications")
          .doc();

        currentBatch.set(notifRef, {
          titleAr,
          titleEn,
          bodyAr,
          bodyEn,
          type,
          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
          source: "shipping_update",
        });

        writeCount++;
        if (writeCount >= BATCH_SIZE) {
          await currentBatch.commit();
          currentBatch = db.batch();
          writeCount = 0;
        }
      }

      if (writeCount > 0) {
        await currentBatch.commit();
      }

      await Promise.all(fcmPromises);

      logger.info(
        `Successfully broadcasted shipping update notification to ${usersSnapshot.size} users.`
      );
    } catch (error) {
      logger.error("Error broadcasting shipping update notification:", error);
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════
// 6. Order Deleted: Rollback Product Selling Counts + Analytics Aggregation
// ═══════════════════════════════════════════════════════════════════════════
exports.onOrderDeleted = onDocumentDeleted(
  "orders/{orderDocId}",
  async (event) => {
    const orderData = event.data?.data();
    if (!orderData) return;

    const batch = db.batch();
    const orderDocId = event.params.orderDocId;

    // 1. Rollback product sellingCount if it was previously applied
    const status = (orderData.status || "").toLowerCase().trim();
    const sellingApplied =
      orderData.sellingCountApplied === true ||
      (orderData.sellingCountApplied === undefined && status !== "cancelled");
    const orderItems = orderData.orderItems || [];

    if (sellingApplied && Array.isArray(orderItems) && orderItems.length > 0) {
      for (const item of orderItems) {
        const productCode = item.code || item.fruitCode || item.productId;
        const qty = Number(item.quantity) || 1;
        if (!productCode || qty <= 0) continue;

        const productRef = db.collection("products").doc(String(productCode));
        batch.set(
          productRef,
          { sellingCount: FieldValue.increment(-qty) },
          { merge: true }
        );
      }
    }

    // 2. Rollback Analytics (Revenue, order counts, status, daily map)
    applyOrderAnalyticsDelta(batch, orderData, -1);

    try {
      await batch.commit();
      logger.info(
        `Successfully rolled back sellingCount and analytics for deleted order ${orderDocId}`
      );
    } catch (error) {
      logger.error(
        `Failed to roll back data for deleted order ${orderDocId}:`,
        error
      );
    }
  }
);

// ── Shared Helper Functions ──────────────────────────────────────────────────

/**
 * Clean up invalid / unregistered FCM tokens automatically
 */
async function handleFcmError(error, userId) {
  if (
    error.code === "messaging/registration-token-not-registered" ||
    error.code === "messaging/invalid-registration-token"
  ) {
    logger.warn(`Removing invalid FCM token for user ${userId}`);
    try {
      await db.collection("users").doc(userId).update({
        fcmToken: FieldValue.delete(),
      });
    } catch (dbErr) {
      logger.error(`Failed to remove FCM token for user ${userId}:`, dbErr);
    }
  }
}

/**
 * Localized Helper for Order Status Messages
 */
function getOrderStatusMessage(status, orderId, isArabic) {
  switch (status) {
    case "processing":
      return {
        title: isArabic ? "جاري تجهيز طلبك 👨‍🍳" : "Order is being prepared 👨‍🍳",
        body: isArabic
          ? `طلبك رقم #${orderId} قيد التجهيز بعناية بأفضل الفواكه الطازجة.`
          : `Your order #${orderId} is being carefully prepared with fresh fruits.`,
      };
    case "shipped":
      return {
        title: isArabic ? "طلبك في الطريق إليك! 🚚" : "Order is on the way! 🚚",
        body: isArabic
          ? `المندوب في طريقه لتسليم طلبك رقم #${orderId}. استعد للاستلام!`
          : `The delivery representative is on the way with your order #${orderId}.`,
      };
    case "delivered":
      return {
        title: isArabic
          ? "تم توصيل طلبك بنجاح ✅"
          : "Order Delivered Successfully ✅",
        body: isArabic
          ? `تم تسليم طلبك رقم #${orderId}. نتمنى لك تجربة ممتعة مع Fruit Hub!`
          : `Your order #${orderId} has been delivered. Enjoy your fresh fruits!`,
      };
    case "cancelled":
      return {
        title: isArabic ? "تم إلغاء الطلب ❌" : "Order Cancelled ❌",
        body: isArabic
          ? `تم إلغاء طلبك رقم #${orderId}. يمكنك التواصل معنا للمساعدة.`
          : `Your order #${orderId} has been cancelled. Contact support if needed.`,
      };
    default:
      return null;
  }
}

/**
 * Helper to adjust product selling counts atomically in batch
 */
async function adjustProductSellingCounts(
  orderItems,
  multiplier,
  orderRef,
  newAppliedStatus,
  orderDocId
) {
  if (!Array.isArray(orderItems) || orderItems.length === 0) return;

  const batch = db.batch();
  let validItemsCount = 0;

  for (const item of orderItems) {
    const productCode = item.code || item.fruitCode || item.productId;
    const qty = Number(item.quantity) || 1;
    const delta = qty * multiplier;

    if (!productCode || delta === 0) continue;

    const productRef = db.collection("products").doc(String(productCode));
    batch.set(
      productRef,
      { sellingCount: FieldValue.increment(delta) },
      { merge: true }
    );
    validItemsCount++;
  }

  if (validItemsCount > 0 && orderRef) {
    batch.update(orderRef, { sellingCountApplied: newAppliedStatus });
    await batch.commit();
    logger.info(
      `Adjusted sellingCount (${multiplier > 0 ? "+1" : "-1"} direction) for ${validItemsCount} products in order ${orderDocId}`
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. One-Time Backfill Analytics (Callable via HTTP)
// ═══════════════════════════════════════════════════════════════════════════
exports.backfillAnalytics = onRequest(
  { region: "europe-west3", cors: true },
  async (req, res) => {
    try {
      logger.info("Starting analytics backfill from existing orders...");
      const ordersSnap = await db.collection("orders").get();
      if (ordersSnap.empty) {
        return res.json({ message: "No orders found to backfill.", count: 0 });
      }

      let totalRevenue = 0;
      let totalOrders = 0;
      const statusCounts = {
        pendingOrders: 0,
        processingOrders: 0,
        shippedOrders: 0,
        deliveredOrders: 0,
        cancelledOrders: 0,
      };
      const paymentMethods = {
        paypal: 0,
        credit_card: 0,
        cash_on_delivery: 0,
      };

      const dailyMap = {};

      for (const doc of ordersSnap.docs) {
        const order = doc.data() || {};
        const price = Number(order.totalPrice ?? 0);
        const statusField = statusToField(order.status);
        const paymentField = paymentMethodToField(order.paymentMethod);
        const dateKey = extractDateKey(order.date);
        const items = Array.isArray(order.orderItems) ? order.orderItems : [];

        totalRevenue += price;
        totalOrders += 1;
        statusCounts[statusField] = (statusCounts[statusField] || 0) + 1;
        paymentMethods[paymentField] = (paymentMethods[paymentField] || 0) + 1;

        if (!dailyMap[dateKey]) {
          dailyMap[dateKey] = {
            date: dateKey,
            revenue: 0,
            ordersCount: 0,
            orderStatuses: {
              pendingOrders: 0,
              processingOrders: 0,
              shippedOrders: 0,
              deliveredOrders: 0,
              cancelledOrders: 0,
            },
            paymentMethods: {
              paypal: 0,
              credit_card: 0,
              cash_on_delivery: 0,
            },
            products: {},
          };
        }

        dailyMap[dateKey].revenue += price;
        dailyMap[dateKey].ordersCount += 1;
        dailyMap[dateKey].orderStatuses[statusField] = (dailyMap[dateKey].orderStatuses[statusField] || 0) + 1;
        dailyMap[dateKey].paymentMethods[paymentField] = (dailyMap[dateKey].paymentMethods[paymentField] || 0) + 1;

        for (const item of items) {
          const code = item.code || item.fruitCode || item.productId || "";
          if (!code) continue;
          const itemPrice = Number(item.price ?? 0);
          const qty = Number(item.quantity ?? 1);
          const rev = itemPrice * qty;

          if (!dailyMap[dateKey].products[code]) {
            dailyMap[dateKey].products[code] = {
              code: String(code),
              name: item.name || "",
              imagePath: item.imageUrl || item.imagePath || "",
              quantitySold: 0,
              revenue: 0,
            };
          }

          dailyMap[dateKey].products[code].quantitySold += qty;
          dailyMap[dateKey].products[code].revenue += rev;
        }
      }

      // Write summary doc
      const summaryRef = db.collection(ANALYTICS_COLLECTION).doc(SUMMARY_DOC);
      await summaryRef.set(
        {
          totalRevenue,
          totalOrders,
          ...statusCounts,
          paymentMethods,
          lastBackfilledAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      // Clean up deprecated analytics/daily document and subcollection if present
      try {
        const oldDailySub = await db
          .collection(ANALYTICS_COLLECTION)
          .doc("daily")
          .collection("daily")
          .get();
        if (!oldDailySub.empty) {
          const cleanupBatch = db.batch();
          for (const d of oldDailySub.docs) {
            cleanupBatch.delete(d.ref);
          }
          await cleanupBatch.commit();
        }
        await db.collection(ANALYTICS_COLLECTION).doc("daily").delete();
      } catch (cleanupErr) {
        logger.warn("Old daily doc cleanup notice:", cleanupErr);
      }

      // Write daily docs in batches of 400
      const dayEntries = Object.entries(dailyMap);
      const BATCH_SIZE = 400;
      for (let i = 0; i < dayEntries.length; i += BATCH_SIZE) {
        const chunk = dayEntries.slice(i, i + BATCH_SIZE);
        const batch = db.batch();
        for (const [dateKey, dayData] of chunk) {
          const dailyRef = db.collection(DAILY_COLLECTION).doc(dateKey);
          batch.set(dailyRef, dayData, { merge: true });
        }
        await batch.commit();
      }

      logger.info(
        `Backfill completed successfully: ${totalOrders} orders, total revenue: ${totalRevenue}`
      );
      res.json({
        success: true,
        totalOrders,
        totalRevenue,
        daysCount: dayEntries.length,
      });
    } catch (error) {
      logger.error("Backfill failed:", error);
      res.status(500).json({ error: error.message });
    }
  }
);
