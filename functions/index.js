//const { admin } = require('firebase-admin/lib/database');
const functions = require('firebase-functions');
const admin = require ("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot, context) => {
        console.log("Follower Created", snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;
    // Create followed user's posts ref
        const followedUserPostsRef = admin
            .firestore()
            .collection("posts")
            .doc(userId)
            .collection("userPosts");
    
    // Create following user's timeline ref
        const timelinePostsRef = admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts");
    // get the followed user's posts
        const querySnapshot = await followedUserPostsRef.get();

    // Add each users posts to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        })
    });

    exports.onDeleteFollower = functions.firestore
        .document("/followers/{userId}/userFollowers/{followerId}")
        .onDelete(async (snapshot, context) => {
            console.log("Follower Deleted", snapshot.id);

            const userId = context.params.userId;
            const followerId = context.params.followerId;

            const timelinePostsRef = admin
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .where("ownerId", "==", userId);

            const querySnapshot = await timelinePostsRef.get();
            querySnapshot.forEach(doc => {
                if (doc.exists) {
                    doc.ref.delete();
                }
            })
        })

    // when a post is created, add post to timeline of each follower (of post owner)

    exports.onCreatePost = functions.firestore
        .document("/posts/{userId}/userPosts/{postId}")
        .onCreate(async (snapshot, context) => {
            const postCreated = snapshot.data();
            const userId = context.params.userId;
            const postId = context.params.postId;

            // Get all the follwers of the user that made the post
            const userFollowersRef = admin.firestore()
                .collection("followers")
                .doc(userId)
                .collection("userFollowers");
            
            const querySnapshot = await userFollowersRef.get();
            // Add the new post to each follers timeline
            querySnapshot.forEach(doc => {
                const followerId = doc.id;

            admin 
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .set(postCreated);
            });
        });

    exports.onUpdatePost = functions.firestore
        .document("/posts/{userId}/userPosts/{postId}")
        .onUpdate(async (change, context) => {
            const postUpdated = change.after.data();
            const userId = context.params.userId;
            const postId = context.params.postId;

            const userFollowersRef = admin.firestore()
                .collection("followers")
                .doc(userId)
                .collection("userFollowers");

            const querySnapshot = await userFollowersRef.get();
            // Update each post on each followers timeline
            querySnapshot.forEach(doc => {
                const followerId = doc.id;

            admin 
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }
                });
            });
        });
    
    exports.onDeletePost = functions.firestore
        .document("/posts/{userId}/userPosts/{postId}")
        .onDelete(async (snapshot, context) => {
            const userId = context.params.userId;
            const postId = context.params.postId;

            const userFollowersRef = admin.firestore()
                .collection("followers")
                .doc(userId)
                .collection("userFollowers");

            const querySnapshot = await userFollowersRef.get();
            // Delete each post on each followers timeline
            querySnapshot.forEach(doc => {
                const followerId = doc.id;

            admin 
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
                });
            });
        });