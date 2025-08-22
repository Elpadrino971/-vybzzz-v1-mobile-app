'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "5dbdd20966cd9f38838cfceca49e4bbd",
"version.json": "1410e44c8a5bca717d08bf537672e5fb",
"index.html": "0d0373b28bd8428d1194acba0bf91f5c",
"/": "0d0373b28bd8428d1194acba0bf91f5c",
"main.dart.js": "05211b94ad351d81cf497f8726794275",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"dashboard.html": "8513182adea58ff503743c6dd6ec2109",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "b68d59f29d8d3a81480ac9173fb5ec06",
"assets/AssetManifest.json": "7e55a1357106ec56fc54a3fbef3107e3",
"assets/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json": "a73f65c04d529966adfe061f4da05fbc",
"assets/ios/Runner/Assets.xcassets/AppIcon.appiconset/ios-marketing.png": "360d29905d19f1d9599fb36cfc1a3fb2",
"assets/NOTICES": "ce1cf950269c4e0d6a9595ccf2517a1c",
"assets/FontManifest.json": "f68c0a9103ef8169d1857dcc6ccce667",
"assets/AssetManifest.bin.json": "0b415ef14b29b1358e6c0aca0b3be019",
"assets/android/app/src/main/res/mipmap-hdpi/ic_launcher.webp": "640451b959d4cd375bb99a56cee5324d",
"assets/android/app/src/main/res/mipmap-hdpi/ic_launcher_round.webp": "e145c088ad36930ca526ec0e47e1e1ad",
"assets/android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.webp": "30dd358cde4beac854387e5299d2e504",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "6edfd3b3d002430b66444cb9cfaa3b54",
"assets/fonts/MaterialIcons-Regular.otf": "00fe0468a5ec5792cd41aef75454ddf8",
"assets/assets/filters/README.md": "57c4304644eae8f1eb00a3b8b064459b",
"assets/assets/audios/battle_start.mp3": "c7c53c8260d77e23cea0546e0e105336",
"assets/assets/audios/win_sound.mp3": "930045719243f6cbf7e6404d64c82935",
"assets/assets/audios/end_countdown.mp3": "066947d877278d8b21aed0ccdfb6c773",
"assets/assets/images/ic_battle_view.png": "05177de16856e9aae8ea4bc70c328974",
"assets/assets/images/ic_background.jpg": "1bdd517fab3467656fc706a0f66a0ae9",
"assets/assets/images/ic_no_filter.png": "e9fe52959881521759d97cf4634c73d8",
"assets/assets/images/grey_picture.jpeg": "a5673843a2bf39efccf56fe518d6ccba",
"assets/assets/images/ic_no_image.png": "e9238a237fff6d5242c448b78ee1e8bc",
"assets/assets/images/ic_user_placeholder.png": "2d75ddf419ab55ff4116a79d3d9e8e98",
"assets/assets/csv/countries.csv": "140c865e0dc6a0ab65e2c45c234faa12",
"assets/assets/icons/ic_post_comment.png": "f6bb3fb523ea8b2296b0b05c7962f7e8",
"assets/assets/icons/ic_google.png": "7616708bbce242702c1252dbfd833a9c",
"assets/assets/icons/ic_chat_play.png": "e0e534599ccef9f46efbf2e7c60ff373",
"assets/assets/icons/ic_hashtag.png": "550083abef9ca655cea5bee1a8d2f148",
"assets/assets/icons/ic_mic_off.png": "a51c012e214bd118e51b02db6fd93096",
"assets/assets/icons/ic_bookmark.png": "a772a71bb4d6629192e71be6e0582ea6",
"assets/assets/icons/ic_chat_1.png": "0e5e2619f7e6c1cf6f6808063f23e923",
"assets/assets/icons/ic_no_ads.png": "2c132ece7b29ba01d16c4197970cd84c",
"assets/assets/icons/ic_voice.png": "edace4d50f8f84d7b5a4aabb360fec99",
"assets/assets/icons/ic_gift_2.png": "0bdd87a377d9edb666ded2ad8ec84dae",
"assets/assets/icons/ic_notification.png": "ba7018254c9a5a56619408383b8349ab",
"assets/assets/icons/ic_down_arrow.png": "37c806e8d06f523e26a6171745713b34",
"assets/assets/icons/ic_story.png": "316156643a000e503517df7de303aabe",
"assets/assets/icons/ic_text_opacity.png": "b60d8f9a97ad9d64307570d8f9e54fc5",
"assets/assets/icons/ic_eye_2.png": "0824a08488fadaa623c5c9bc5ac255cc",
"assets/assets/icons/ic_live_stream.png": "4f9404d8c7076b7d406b2d0d162ef1cd",
"assets/assets/icons/ic_crown.png": "72c870f4fdee367dce708e10e052c9f0",
"assets/assets/icons/ic_message.png": "29a714d3c3f66efd0b00cb7da3f5d0ae",
"assets/assets/icons/ic_sticker.png": "4ccf0baf37183d59cb6f4d94baa194f4",
"assets/assets/icons/ic_image.png": "d55e5b483d40c6e273cae60da02b7e02",
"assets/assets/icons/ic_gift_1.png": "1da9ecabac5642442b4c969f60115a94",
"assets/assets/icons/ic_report.png": "06a4e7feb13d95e6efa512997b6d853b",
"assets/assets/icons/ic_language.png": "1f58d09c710ace631529b38582d20cf0",
"assets/assets/icons/ic_battle_vs.png": "9c6b3dd33adfada9c44a1d693b564939",
"assets/assets/icons/ic_close.png": "347cf04e141db07dd02e4ab9393819d4",
"assets/assets/icons/ic_check_circle.png": "4c9de0bd535f770be874c388f4241762",
"assets/assets/icons/ic_speaker.png": "27559ab008ff61c0348cf07b998e6c71",
"assets/assets/icons/ic_eye_1.png": "04a1ed305b6709250abd2fa1ec7d44f5",
"assets/assets/icons/ic_image1.png": "d81ca5374ef44b9f9f0cabcede2c5636",
"assets/assets/icons/ic_location.png": "8bc0274d84baea092572a37cb2e9ebd3",
"assets/assets/icons/ic_camera.png": "2a1b56eee274e29abf8f6ac501ff9122",
"assets/assets/icons/ic_play_1.png": "bf713054a794a6d36796421ac1cc0177",
"assets/assets/icons/ic_notification_1.png": "594510437dd4eeca97fe10c17a9d7c0d",
"assets/assets/icons/ic_heart.png": "ccd4828eebd0bf58a1a10a8392807642",
"assets/assets/icons/ic_apple.png": "928ea13a166ef17b80b430d4a7304192",
"assets/assets/icons/ic_block.png": "62c34fdc7949cf86327d1bac67858ab2",
"assets/assets/icons/ic_hide_eye.png": "2c6349fdfb9335a98eccd097db7ea2af",
"assets/assets/icons/ic_speaker_mute.png": "a46f1e86a0bcff49e7895963e734f0bb",
"assets/assets/icons/ic_whatsapp.png": "0f2a6f55f056cdaf7d542a943c1bb874",
"assets/assets/icons/ic_verified_white.png": "952ef89ae4d6eba7916fc9e4b883e099",
"assets/assets/icons/ic_plus.png": "4acd2954667db0f626ea9fca9d03a359",
"assets/assets/icons/ic_more_1.png": "9c23bf40e414e933364e3236b1fd7800",
"assets/assets/icons/ic_right_arrow.png": "b44165e92f981ce9a70ab07d3b568e77",
"assets/assets/icons/ic_pause.png": "ca8b51a1185f22738796aa746e426f9e",
"assets/assets/icons/ic_fill_bookmark_1.png": "de8390575109b8ac9a786819e3c7f045",
"assets/assets/icons/ic_camera_flip.png": "bf8aaac908768620dadac179cce9eee4",
"assets/assets/icons/ic_blue_tick.png": "41a9c93f065010e8f62265021b488a4a",
"assets/assets/icons/ic_post.png": "b76e54fd01098de3cb4b204d8d0c70ec",
"assets/assets/icons/ic_delete.png": "73ed46363248e273ac3660368ebc414b",
"assets/assets/icons/ic_session_expired.png": "7fc35d4e07e95c84bbe8afef2c462b01",
"assets/assets/icons/ic_link.png": "c0ebd1ca0d9c0eab0c843049b837df0d",
"assets/assets/icons/ic_profile.png": "93cfed1ca1c82949e04231c64e5919af",
"assets/assets/icons/ic_link_placeholder.png": "d13c8c041c1b490e203ffa908debd4aa",
"assets/assets/icons/ic_video.png": "428a74345735ebe2c14dd128ebd30bbf",
"assets/assets/icons/ic_back_arrow.png": "6e0ec526eae61b74410b0928dfc82445",
"assets/assets/icons/ic_video_camera.png": "820b49b87880f6cc7745169e0adc932d",
"assets/assets/icons/ic_microphone.png": "e4e99671aea56835520c325e44bd977a",
"assets/assets/icons/ic_comment.png": "5653ca9edd66714dc2b560916c1c7484",
"assets/assets/icons/ic_filter.png": "3a4df918ffe96402ef3b788465d9a4eb",
"assets/assets/icons/ic_qr_code.png": "50c1dfc70ab39747dbe0012895f15202",
"assets/assets/icons/ic_share.png": "10d82b4d6d4d07848fd0050785fc311d",
"assets/assets/icons/ic_post_bookmark.png": "29aaa37563ccd22faf113eb507ec149a",
"assets/assets/icons/ic_no_flash.png": "e5fc99f9826ae0955dac0d9015de642e",
"assets/assets/icons/ic__locatio_pin.png": "9001d50f6153280642e8bfd69547eb71",
"assets/assets/icons/ic_instagram.png": "39c726b02d739532e304b964f880864c",
"assets/assets/icons/ic_text_style.png": "c2a1bbf0976c6cbb7eb81bc66b002393",
"assets/assets/icons/ic_text_font.png": "602fb3d96e450dc6a218990a58eeda26",
"assets/assets/icons/ic_fill_bookmark.png": "78813beb485bffbdd8aa1204e63b002a",
"assets/assets/icons/ic_logout.png": "853c305da00adcf2ff8f59d6cada339b",
"assets/assets/icons/ic_pinned.png": "2e9367ec4dc13780b4f944491faf4e25",
"assets/assets/icons/ic_forward_arrow.png": "c7fa2df7a871b01c98dd37b95d7ad764",
"assets/assets/icons/ic_more.png": "1b99491ab4d38eaaec560a648c34498e",
"assets/assets/icons/ic_share_2.png": "2c5e5203d5efa7c0248f7ac1fcb24a62",
"assets/assets/icons/ic_star.png": "985c1ec70ac4bea8677c90fb080db245",
"assets/assets/icons/ic_back_arrow_1.png": "8fbd9218f2d2c9825d6c048dd1b0b1b2",
"assets/assets/icons/ic_edit.png": "e61d3e8fe3009aea774a085717520704",
"assets/assets/icons/ic_reel.png": "ed3b1a180ace78fc42f5294eb324063d",
"assets/assets/icons/ic_music.png": "e45bdca111870f9f3d8843e1584e031e",
"assets/assets/icons/ic_alert.png": "a85f53cd7388e10d130e6ca9e659b042",
"assets/assets/icons/ic_share_1.png": "060136142b6bafdb2dcf716eecc19a49",
"assets/assets/icons/ic_live_1.png": "080c5548374efa89bb4166367bb0ed88",
"assets/assets/icons/ic_freeze.png": "909584fd0c09c06659ca4e2f652d0aec",
"assets/assets/icons/ic_telegram.png": "787637be026e185cb4e1f398b0c4aec4",
"assets/assets/icons/ic_search.png": "8b1f87f4ccd993cc37098fca50620fda",
"assets/assets/icons/ic_upload_gallery.png": "3de61429cb04c7a10b15dc925b3aebda",
"assets/assets/icons/ic_live.png": "75b95972c76642f55dd898d380936e05",
"assets/assets/icons/ic_down_arrow_1.png": "80f8f75a540f755d7f52b5779dfa014c",
"assets/assets/icons/ic_copy.png": "200303e3df96bafd8790382c32055b05",
"assets/assets/icons/ic_text.png": "c0732dfc145569f189b5afc6df8c5a33",
"assets/assets/icons/ic__text_font_family.png": "fe8bd38dfb6f678220b13849a5391d48",
"assets/assets/icons/ic_download.png": "5a670fe463600267e408b259f7abb715",
"assets/assets/icons/ic_pro.png": "8284b312a0c8500aeca13b50f0686a08",
"assets/assets/icons/ic_video_request.png": "f57ca7791c41bb42d6dc235325114fef",
"assets/assets/icons/ic_play.png": "53e90f301af9ae4bf5587b4e9f1dae46",
"assets/assets/icons/ic_close_1.png": "e7f43c00ec0c4f734e083ec308160943",
"assets/assets/icons/ic_post_share.png": "a4d6b5d1c43a5539dd899c5415ef4f07",
"assets/assets/icons/ic_coin.png": "2fd8aab156ed55534e62843d18125fe4",
"assets/assets/icons/ic_chat.png": "714f1ac8dac091772d69df3dd86ee3e4",
"assets/assets/icons/ic_qr_code_1.png": "93e25a7e1af81b6bde7e58314dd16005",
"assets/assets/icons/ic_audience.png": "2bdbb4bac4d1d4e4c4e702a311cdccad",
"assets/assets/icons/ic_language_1.png": "1fc940aa4b8567c72b63e13914b1a2da",
"assets/assets/icons/ic_text_1.png": "2222827aa562f4dce2e813931698a87a",
"assets/assets/icons/ic_at.png": "9ad45395c01fbeabbc0af9879643f8d0",
"assets/assets/icons/ic_wallet.png": "69d546d997336175025cb70f69dc66c4",
"assets/assets/icons/ic_flip.png": "d85f40c0ba6232a385ac08c9c83d492c",
"assets/assets/icons/ic_delete1.png": "60fc362d1fd8458d73b6cd398d087b5e",
"assets/assets/icons/marker_pin.png": "9425b433198fe89a56d5a8f3e320d821",
"assets/assets/icons/ic_check.png": "d37c4923d04069ea7706e2059c70ffe4",
"assets/assets/icons/ic_text_color.png": "ecf05fa93ff50c15fba79951783391ef",
"assets/assets/icons/ic_delete2.png": "5f28195262b146b5591198c69e9cebfe",
"assets/assets/icons/ic_fill_heart.png": "f3e3a7651a113d1ce1320437cd809667",
"assets/assets/icons/ic_flash.png": "5cc3aa2fe7b6fe493a424af6394f20e5",
"assets/assets/icons/ic_follow.png": "bbe2e65a3566d47dbbafc8bed8fa6efe",
"assets/assets/icons/ic_video_off.png": "f739087d1e2c2ae732811559332e67eb",
"assets/assets/icons/ic_gift.png": "e31c4f06832ba1f83b9df57cb22742b4",
"assets/assets/icons/ic_location_pin.png": "9001d50f6153280642e8bfd69547eb71",
"assets/assets/icons/ic_edit_1.png": "f14ccfc813db8c1ad17cef821304a2eb",
"assets/assets/icons/ic_expand.png": "cb880bcf05c2726b65515a156c964880",
"assets/assets/icons/ic_no_internet.png": "d2f3d4badd9e1811fcf0da41bdb7b266",
"assets/assets/icons/ic_eye.png": "6c45b60565b048b4b9ae31e089857018",
"assets/assets/fonts/Outfit-Bold.ttf": "e28d1b405645dfd47f4ccbd97507413c",
"assets/assets/fonts/Outfit-Black.ttf": "d032ccd62028487a6c8d70a07bda684b",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
