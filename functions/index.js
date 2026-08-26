const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Scheduled Cloud Function running every minute to detect inactive journeys.
 * If an active journey has no location update for > 5 minutes, flag it and notify trusted contacts.
 */
exports.checkInactivityAlerts = functions.pubsub
    .schedule("every 1 minutes")
    .onRun(async (context) => {
      const now = new Date();
      const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);

      const activeJourneys = await admin
          .firestore()
          .collection("journeys")
          .where("isActive", "==", true)
          .where("isInactivityAlerted", "==", false)
          .get();

      const batch = admin.firestore().batch();
      const notifications = [];

      activeJourneys.forEach((doc) => {
        const journey = doc.data();
        const lastLoc = journey.lastKnownLocation;

        if (lastLoc && lastLoc.timestamp) {
          const lastUpdate = new Date(lastLoc.timestamp);
          if (lastUpdate < fiveMinutesAgo) {
            // Flag inactivity in Firestore
            batch.update(doc.ref, { isInactivityAlerted: true });

            // Prepare push notifications to contacts
            if (journey.contactIds && journey.contactIds.length > 0) {
              const payload = {
                notification: {
                  title: "SafeCircle Inactivity Alert!",
                  body: `User has stopped moving for over 5 minutes during an active journey.`,
                },
                data: {
                  journeyId: doc.id,
                  type: "INACTIVITY_ALERT",
                },
              };

              journey.contactIds.forEach((contactId) => {
                notifications.push(
                    admin.messaging().sendToTopic(`contact_${contactId}`, payload)
                );
              });
            }
          }
        }
      });

      await batch.commit();
      await Promise.all(notifications);
      console.log(`Inactivity check complete. Evaluated ${activeJourneys.size} journeys.`);
      return null;
    });

/**
 * Trigger function when journey document is updated with battery critical status.
 */
exports.onBatteryAlertTriggered = functions.firestore
    .document("journeys/{journeyId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      if (!before.isBatteryAlerted && after.isBatteryAlerted) {
        const payload = {
          notification: {
            title: "SafeCircle Battery Alert",
            body: "User's device battery dropped below 15% during an active journey.",
          },
          data: {
            journeyId: context.params.journeyId,
            type: "BATTERY_ALERT",
          },
        };

        if (after.contactIds && after.contactIds.length > 0) {
          const promises = after.contactIds.map((cId) =>
            admin.messaging().sendToTopic(`contact_${cId}`, payload)
          );
          await Promise.all(promises);
        }
      }
    });
