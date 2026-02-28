import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

import 'customWidgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar(
      {Key? key,
      this.leading,
      this.title,
      this.actions,
      this.scaffoldKey,
      this.icon,
      this.onActionPressed,
      this.textController,
      this.isBackButton = false,
      this.isCrossButton = false,
      this.submitButtonText,
      this.isSubmitDisable = true,
      this.isbootomLine = true,
      this.onSearchChanged})
      : super(key: key);

  final List<Widget>? actions;
  final Size appBarHeight = Size.fromHeight(56.0);
  final IconData? icon;
  final bool isBackButton;
  final bool isbootomLine;
  final bool isCrossButton;
  final bool isSubmitDisable;
  final Widget? leading;
  final Function? onActionPressed;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? submitButtonText;
  final TextEditingController? textController;
  final Widget? title;
  final ValueChanged<String>? onSearchChanged;

  @override
  Size get preferredSize => appBarHeight;

  Widget _searchField(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          onChanged: onSearchChanged ?? (_) {},
          controller: textController,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(radiusCard),
            ),
            hintText: 'Arama..',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            fillColor: theme.colorScheme.surface,
            filled: true,
            focusColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        ));
  }

  List<Widget> _getActionButtons(BuildContext context) {
    return <Widget>[
      submitButtonText != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: customInkWell(
                context: context,
                radius: BorderRadius.circular(40),
                onPressed: () {
                  onActionPressed?.call();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isSubmitDisable
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withAlpha(150),
                    borderRadius: BorderRadius.circular(radiusCard),
                  ),
                  child: Text(
                    submitButtonText ?? '',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            )
              : icon == null
              ? Container()
              : IconButton(
                  onPressed: () {
                    onActionPressed?.call();
                  },
                  icon: customIcon(context,
                      icon: icon!,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 25),
                )
    ];
  }

  Widget _getUserAvatar(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: customInkWell(
        context: context,
        onPressed: () {
          scaffoldKey?.currentState?.openDrawer();
        },
        child:
            customProfileImage(context, authState.userModel?.profilePic, userId: authState.userModel?.userId, height: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      iconTheme: IconThemeData(color: theme.colorScheme.primary),
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: isBackButton
          ? BackButton()
          : isCrossButton
              ? IconButton(
                  color: AppColor.primary,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : _getUserAvatar(context),
      title: title != null ? title : _searchField(context),
      actions: _getActionButtons(context),
      bottom: PreferredSize(
        child: Container(
          color: isbootomLine
              ? Theme.of(context).dividerColor
              : Theme.of(context).colorScheme.surface,
          height: 1.0,
        ),
        preferredSize: Size.fromHeight(0.0),
      ),
    );
  }
}
