import 'templates/button.dart';
import 'templates/input.dart';
import 'templates/select.dart';
import 'templates/card.dart';
import 'templates/badge.dart';
import 'templates/checkbox.dart';
import 'templates/switch.dart';
import 'templates/textarea.dart';
import 'templates/radio.dart';
import 'templates/tabs.dart';
import 'templates/toast.dart';
import 'templates/dialog.dart';
import 'templates/icon_button.dart';
import 'templates/dropdown_menu.dart';
import 'templates/date_picker.dart';
import 'templates/slider.dart';
import 'templates/avatar.dart';
import 'templates/list_tile.dart';
import 'templates/progress.dart';
import 'templates/table.dart';
import 'templates/chip.dart';
import 'templates/tooltip.dart';
import 'templates/bottom_sheet.dart';
import 'templates/snackbar.dart';
import 'templates/app_bar.dart';
import 'templates/bottom_nav.dart';
import 'templates/navigation_rail.dart';
import 'templates/drawer.dart';
import 'templates/search_bar.dart';
import 'templates/alert.dart';
import 'templates/banner.dart';
import 'templates/empty_state.dart';
import 'templates/skeleton.dart';
import 'templates/divider.dart';
import 'templates/pagination.dart';
import 'templates/breadcrumb.dart';
import 'templates/page_header.dart';
import 'templates/rating.dart';
import 'templates/stat_card.dart';
import 'templates/timeline.dart';

/// Component name to template string mapping.
const componentTemplates = {
  'button': buttonTemplate,
  'input': inputTemplate,
  'select': selectTemplate,
  'card': cardTemplate,
  'badge': badgeTemplate,
  'checkbox': checkboxTemplate,
  'switch': switchTemplate,
  'textarea': textareaTemplate,
  'radio': radioTemplate,
  'tabs': tabsTemplate,
  'toast': toastTemplate,
  'dialog': dialogTemplate,
  'icon_button': iconButtonTemplate,
  'dropdown_menu': dropdownMenuTemplate,
  'date_picker': datePickerTemplate,
  'slider': sliderTemplate,
  'avatar': avatarTemplate,
  'list_tile': listTileTemplate,
  'progress': progressTemplate,
  'table': tableTemplate,
  'chip': chipTemplate,
  'tooltip': tooltipTemplate,
  'bottom_sheet': bottomSheetTemplate,
  'snackbar': snackbarTemplate,
  'app_bar': appBarTemplate,
  'bottom_nav': bottomNavTemplate,
  'navigation_rail': navigationRailTemplate,
  'drawer': drawerTemplate,
  'search_bar': searchBarTemplate,
  'alert': alertTemplate,
  'banner': bannerTemplate,
  'empty_state': emptyStateTemplate,
  'skeleton': skeletonTemplate,
  'divider': dividerTemplate,
  'pagination': paginationTemplate,
  'breadcrumb': breadcrumbTemplate,
  'page_header': pageHeaderTemplate,
  'rating': ratingTemplate,
  'stat_card': statCardTemplate,
  'timeline': timelineTemplate,
};

/// Component categories for grouped listing.
const componentCategories = {
  'Inputs': [
    'button',
    'input',
    'select',
    'textarea',
    'checkbox',
    'radio',
    'switch',
    'slider',
    'date_picker',
    'search_bar',
    'icon_button',
    'rating',
  ],
  'Layout': [
    'card',
    'divider',
    'drawer',
    'tabs',
    'app_bar',
    'bottom_nav',
    'navigation_rail',
    'table',
    'list_tile',
    'pagination',
    'breadcrumb',
    'page_header',
    'timeline',
  ],
  'Feedback': [
    'alert',
    'banner',
    'toast',
    'snackbar',
    'dialog',
    'bottom_sheet',
    'progress',
    'skeleton',
    'empty_state',
  ],
  'Display': [
    'avatar',
    'badge',
    'chip',
    'tooltip',
    'dropdown_menu',
    'stat_card',
  ],
};

/// Component dependencies — which components require others.
const componentDependencies = <String, List<String>>{
  'search_bar': ['input'],
  'dropdown_menu': ['button'],
  'date_picker': ['button', 'input'],
  'dialog': ['button'],
  'bottom_sheet': ['button'],
  'snackbar': ['button'],
  'toast': ['button'],
  'pagination': ['button'],
  'empty_state': ['button'],
};

/// Component name to short description mapping.
const componentDescriptions = {
  'button': 'Buttons with variants, sizes, and loading states.',
  'input': 'Text input with labels, helpers, and prefix/suffix.',
  'select': 'Custom dropdown select with overlay menu.',
  'card': 'Elevated surface with border and radius.',
  'badge': 'Small status label (solid/outline/soft).',
  'checkbox': 'Custom checkbox with tristate support.',
  'switch': 'Adaptive switch with label support.',
  'textarea': 'Multiline input with iOS adaptive mode.',
  'radio': 'Custom radio button with label support.',
  'tabs': 'Segmented-style tabs with views.',
  'toast': 'Snackbar-based toast helper.',
  'dialog': 'Adaptive alert dialog helper.',
  'icon_button': 'Icon-only button with variants and sizes.',
  'dropdown_menu': 'Popup menu anchored to any widget.',
  'date_picker': 'Adaptive date picker helper.',
  'slider': 'Adaptive slider with theme tokens.',
  'avatar': 'Avatar with image or initials.',
  'list_tile': 'Custom list tile with hover and border.',
  'progress': 'Linear or circular progress indicator.',
  'table': 'Lightweight data table widget.',
  'chip': 'Tag/chip with variants and delete.',
  'tooltip': 'Themed tooltip wrapper.',
  'bottom_sheet': 'Adaptive bottom sheet helper.',
  'snackbar': 'Snackbar helper with variants.',
  'app_bar': 'App bar wrapper with theming tokens.',
  'bottom_nav': 'Bottom navigation bar wrapper.',
  'navigation_rail': 'Navigation rail wrapper.',
  'drawer': 'Drawer with header/footer slots.',
  'search_bar': 'Search input with icons and theming.',
  'alert': 'Alert/banner with variants.',
  'banner': 'Banner callout with icon, message, and action.',
  'empty_state': 'Empty state with icon, message, and action.',
  'skeleton': 'Animated skeleton loader block.',
  'divider': 'Horizontal or vertical divider.',
  'pagination': 'Page navigation control.',
  'breadcrumb': 'Breadcrumb trail with separators.',
  'page_header': 'Page header with title, subtitle, and actions.',
  'rating': 'Star rating display and input.',
  'stat_card': 'Metric card with label, value, and delta.',
  'timeline': 'Vertical timeline list with active markers.',
};
