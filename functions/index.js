const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

/**
 * 0. Order Created: Update Product Selling Counts
 * Triggers automatically when a new order document is created in `orders/{orderDocId}`
 */
exports.onOrderCreated = onDocumentCreated(
  "orders/{orderDocId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const orderData = snapshot.data();
    if (!orderData) return;

    const status = (orderData.status || "").toLowerCase().trim();
    if (status === "cancelled") return;

    const orderItems = orderData.orderItems || [];
    if (!Array.isArray(orderItems) || orderItems.length === 0) return;

    try {
      await adjustProductSellingCounts(
        orderItems,
        1,
        snapshot.ref,
        true,
        event.params.orderDocId
      );
      logger.info(
        `Successfully incremented sellingCount for new order ${event.params.orderDocId}`
      );
    } catch (error) {
      logger.error(
        `Failed to increment sellingCount for order ${event.params.orderDocId}:`,
        error
      );
    }
  }
);

/**
 * 1. Order Status Changed Notification
 * Triggers when an order document status updates in `orders/{orderDocId}`
 */
exports.onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderDocId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (!beforeData || !afterData) return;

    const oldStatus = (beforeData.status || "").toLowerCase().trim();
    const newStatus = (afterData.status || "").toLowerCase().trim();

    // Only proceed if status has actually changed
    if (!newStatus || oldStatus === newStatus) return;

    const userId = afterData.uId || afterData.userId;
    const orderId =
      afterData.orderId != null ? afterData.orderId : event.params.orderDocId;

    // 0. Handle sellingCount rollback on cancellation or re-apply on un-cancellation
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

    // Fetch user details (fcmToken & languageCode)
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      logger.warn(`User document not found for user: ${userId}`);
      return;
    }

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;
    const isArabic = (userData.languageCode || "ar") === "ar";

    // Build both AR and EN messages for bilingual storage
    const arContent = getOrderStatusMessage(newStatus, orderId, true);
    const enContent = getOrderStatusMessage(newStatus, orderId, false);
    if (!arContent || !enContent) return;

    // Pick the push banner language based on user's current languageCode
    const { title, body } = isArabic ? arContent : enContent;

    // 1. Send FCM Push Notification if token exists
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

    // 2. Save bilingual notification to user in-app notifications collection
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

/**
 * 2. Post-Delivery Review Prompt Notification
 * Triggered only when order transitions to 'delivered'
 */
exports.onOrderDeliveredPromptReview = onDocumentUpdated(
  "orders/{orderDocId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (!beforeData || !afterData) return;

    const beforeStatus = (beforeData.status || "").toLowerCase().trim();
    const afterStatus = (afterData.status || "").toLowerCase().trim();

    // Trigger strictly on transition to 'delivered'
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

    // Find the first product that the user has NOT reviewed yet
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

      // Check strictly by user identity (userId or uId)
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

      // Build bilingual product name (OrderItemModel only has 'name', use it for both)
      const productNameAr = item.name || "المنتج";
      const productNameEn = item.name || "the product";

      const titleAr = "كيف كانت الفواكه؟ ⭐";
      const titleEn = "How was your fruit? ⭐";
      const bodyAr = `شاركنا رأيك في "${productNameAr}" وساعد عملاء آخرين في اختيار الأفضل!`;
      const bodyEn = `Share your review for "${productNameEn}" to help other buyers!`;

      // Push banner uses user's current language
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

/**
 * 3. Abandoned Cart Reminder Notification
 * Runs daily at 18:00 (UTC) with anti-spam protection & batch processing
 */
exports.checkAbandonedCarts = onSchedule(
  {
    schedule: "0 18 * * *",
    timeZone: "UTC",
  },
  async (event) => {
    logger.info("Running checkAbandonedCarts scheduled job...");

    // Query only users that have an FCM token
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

      // Anti-Spam: Do not notify again if notified within the last 48 hours
      const lastReminder = userData.lastCartReminderSentAt?.toMillis?.() || 0;
      if (now - lastReminder < TWO_DAYS_MS) {
        continue;
      }

      candidates.push({ userDoc, userData, fcmToken });
    }

    logger.info(
      `Found ${candidates.length} candidate users for abandoned cart reminders.`
    );

    // Process concurrently in chunks of 20 to prevent execution timeout
    const chunkSize = 20;
    for (let i = 0; i < candidates.length; i += chunkSize) {
      const chunk = candidates.slice(i, i + chunkSize);
      await Promise.allSettled(
        chunk.map(async ({ userDoc, userData, fcmToken }) => {
          const isArabic = (userData.languageCode || "ar") === "ar";
          const titleAr = "سلتك في انتظارك! 🛒";
          const titleEn = "Your cart is waiting! 🛒";
          const bodyAr = "فواكهك المفضلة لا تزال في السلة، أكمل طلبك الآن لتصلك طازجة!";
          const bodyEn = "Your favorite fresh fruits are still in your cart. Complete your order now!";

          // Push banner uses user's current language
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

            // Update timestamp to prevent recurring spam
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

