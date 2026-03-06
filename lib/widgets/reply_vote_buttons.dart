import 'package:flutter/material.dart';
import 'package:toldya/generated/l10n/app_localizations.dart';
import 'package:toldya/model/feedModel.dart';
import 'package:toldya/state/authState.dart';
import 'package:toldya/state/feedState.dart';
import 'package:provider/provider.dart';

/// Yorum kartında Katılıyorum / Katılmıyorum butonları.
class ReplyVoteButtons extends StatelessWidget {
  final String postId;
  final FeedModel model;

  const ReplyVoteButtons({Key? key, required this.postId, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feedState = Provider.of<FeedState>(context, listen: true);
    final authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.userId;
    final up = model.upvoteCount ?? 0;
    final down = model.downvoteCount ?? 0;
    final isUp = (model.upvoteUserIds ?? []).contains(userId);
    final isDown = (model.downvoteUserIds ?? []).contains(userId);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: AppLocalizations.of(context)!.agree,
          child: InkWell(
          onTap: () async {
            try {
              await feedState.voteReply(postId, model.key ?? '', 1);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.voteFailed)),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: isUp ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 2),
                Text(
                  '$up',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUp ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ), ),
        SizedBox(width: 4),
        Tooltip(
          message: AppLocalizations.of(context)!.disagree,
          child: InkWell(
          onTap: () async {
            try {
              await feedState.voteReply(postId, model.key ?? '', -1);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.voteFailed)),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_down_alt_outlined,
                  size: 16,
                  color: isDown ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 2),
                Text(
                  '$down',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDown ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ), ),
      ],
    );
  }
}
