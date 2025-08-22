import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/functions/debounce_action.dart';
import 'package:vybzzz/common/service/api/search_service.dart';
import 'package:vybzzz/common/widget/bottom_sheet_top_view.dart';
import 'package:vybzzz/common/widget/custom_search_text_field.dart';
import 'package:vybzzz/common/widget/search_result_tile.dart';
import 'package:vybzzz/languages/languages_keys.dart';
import 'package:vybzzz/model/post_story/hashtag_model.dart';
import 'package:vybzzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:vybzzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:vybzzz/utilities/app_res.dart';
import 'package:vybzzz/utilities/asset_res.dart';
import 'package:vybzzz/utilities/theme_res.dart';

class HashTagSheet extends StatefulWidget {
  const HashTagSheet({super.key});

  @override
  State<HashTagSheet> createState() => _HashTagSheetState();
}

class _HashTagSheetState extends State<HashTagSheet> {
  final controller = Get.find<CreateFeedScreenController>();
  CommentHelper helper = CommentHelper();
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  TextEditingController textEditingController = TextEditingController();
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    helper = controller.commentHelper;

    searchHashTag();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      decoration: ShapeDecoration(
          color: whitePure(context),
          shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                  top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)))),
      child: Column(
        children: [
          BottomSheetTopView(title: LKey.hashtags.tr, sideBtnVisibility: false),
          CustomSearchTextField(
              controller: textEditingController,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              onChanged: (value) => searchHashTag(reset: true)),
          const SizedBox(height: 10),
          Expanded(
            child: ImageTextListTile(
                items: hashTags,
                onTap: (p0) => controller.commentHelper
                    .appendDetection(p0, DetectType.hashTag, type: 0),
                image: AssetRes.icHashtag,
                getDisplayText: (p0) => '${AppRes.hash}${p0.hashtag ?? ' '}',
                getDisplayDescription: (p0) =>
                    '${p0.postCount} ${LKey.posts.tr}',
                loadMore: searchHashTag,
                isLoading: isLoading),
          )
        ],
      ),
    );
  }

  Future<void> searchHashTag({bool reset = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    DebounceAction.shared.call(() async {
      final data = await SearchService.instance.searchHashtags(
        keyword: textEditingController.text.trim(),
        lastItemId: reset
            ? null
            : hashTags.isEmpty
                ? null
                : hashTags.last.id?.toInt(),
      );
      if (reset) {
        hashTags.clear();
      }
      isLoading.value = false;
      hashTags.addAll(data);
    });
  }
}
