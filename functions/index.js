const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

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

    // Only proceed if status has actually changed
    if (beforeData.status === afterData.status) return;

    const newStatus = afterData.status;
    const userId = afterData.uId || afterData.userId;
    const orderId = afterData.orderId || event.params.orderDocId;

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

    // Build localized message based on status
    const messageContent = getOrderStatusMessage(newStatus, orderId, isArabic);
    if (!messageContent) return;

    const { title, body } = messageContent;

    // 1. Send FCM Push Notification if token exists
    if (fcmToken) {
      try {
        await messaging.send({
          token: fcmToken,
          notification: {
            title,
            body,
          },
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
              icon: "@mipmap/launcher_icon",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        });
        logger.info(`Push notification sent to user ${userId} for order ${orderId} status: ${newStatus}`);
      } catch (error) {
        logger.error(`Failed to send push notification to user ${userId}:`, error);
      }
    }

    // 2. Save notification to user in-app notifications collection
    try {
      await db.collection("users").doc(userId).collection("notifications").add({
        title,
        body,
        type: "order",
        orderId: String(orderId),
        status: String(newStatus),
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    } catch (error) {
      logger.error(`Failed to save notification record for user ${userId}:`, error);
    }
  }
);

/**
 * 2. Post-Delivery Review Prompt Notification
 * When order becomes `delivered`, check products and prompt review
 * ONLY IF the user hasn't reviewed the product yet!
 */
exports.onOrderDeliveredPromptReview = onDocumentUpdated(
  "orders/{orderDocId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (!beforeData || !afterData) return;

    // Trigger only on transition to 'delivered'
    if (beforeData.status === "delivered" || afterData.status !== "delivered") {
      return;
    }

    const userId = afterData.uId || afterData.userId;
    const orderItems = afterData.orderItems || [];

    if (!userId || orderItems.length === 0) return;

    // Get user details
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;
    const isArabic = (userData.languageCode || "ar") === "ar";

    // Find the first product that the user has NOT reviewed yet
    for (const item of orderItems) {
      const productCode = item.fruitCode || item.productId || item.code;
      if (!productCode) continue;

      const productDoc = await db.collection("products").doc(String(productCode)).get();
      if (!productDoc.exists) continue;

      const productData = productDoc.data() || {};
      const reviews = productData.reviews || [];

      // Check if user already reviewed this product
      const hasAlreadyReviewed = reviews.some(
        (r) => r.userId === userId || (r.name && r.name === userData.name)
      );

      if (hasAlreadyReviewed) {
        logger.info(`User ${userId} already reviewed product ${productCode}. Skipping prompt.`);
        continue;
      }

      // Found an unreviewed product: send review prompt!
      const productName = isArabic
        ? (item.nameAr || item.name || "المنتج")
        : (item.nameEn || item.name || "the product");

      const title = isArabic ? "كيف كانت الفواكه؟ ⭐" : "How was your fruit? ⭐";
      const body = isArabic
        ? `شاركنا رأيك في "${productName}" وساعد عملاء آخرين في اختيار الأفضل!`
        : `Share your review for "${productName}" to help other buyers!`;

      // Send push notification
      if (fcmToken) {
        try {
          await messaging.send({
            token: fcmToken,
            notification: { title, body },
            data: {
              type: "review",
              productCode: String(productCode),
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "fruit_hub_notifications",
                icon: "@mipmap/launcher_icon",
              },
            },
          });
          logger.info(`Review prompt sent to user ${userId} for product ${productCode}`);
        } catch (error) {
          logger.error(`Failed to send review prompt to user ${userId}:`, error);
        }
      }

      // Save notification to in-app collection
      await db.collection("users").doc(userId).collection("notifications").add({
        title,
        body,
        type: "review",
        productCode: String(productCode),
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
      });

      // Stop after finding the first unreviewed product to avoid spamming
      break;
    }
  }
);

/**
 * 3. Abandoned Cart Reminder Notification
 * Runs on schedule (e.g. daily at 18:00 UTC) to notify users with items in their cart
 */
exports.checkAbandonedCarts = onSchedule(
  "every 24 hours",
  async (event) => {
    logger.info("Running checkAbandonedCarts scheduled job...");

    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data() || {};
      const cartItems = userData.cartItems || [];
      const fcmToken = userData.fcmToken;

      // Only notify if user has cart items and an FCM token
      if (cartItems.length === 0 || !fcmToken) continue;

      const isArabic = (userData.languageCode || "ar") === "ar";
      const title = isArabic ? "سلتك في انتظارك! 🛒" : "Your cart is waiting! 🛒";
      const body = isArabic
        ? "فواكهك المفضلة لا تزال في السلة، أكمل طلبك الآن لتصلك طازجة!"
        : "Your favorite fresh fruits are still in your cart. Complete your order now!";

      try {
        await messaging.send({
          token: fcmToken,
          notification: { title, body },
          data: {
            type: "cart",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "fruit_hub_notifications",
              icon: "@mipmap/launcher_icon",
            },
          },
        });

        await db.collection("users").doc(userDoc.id).collection("notifications").add({
          title,
          body,
          type: "cart",
          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
        });

        logger.info(`Abandoned cart reminder sent to user: ${userDoc.id}`);
      } catch (error) {
        logger.error(`Error sending abandoned cart notification to ${userDoc.id}:`, error);
      }
    }
  }
);

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
        title: isArabic ? "تم توصيل طلبك بنجاح ✅" : "Order Delivered Successfully ✅",
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
