# انتبه: شغّل هذا السكربت من داخل مجلد مشروع Flutter (shoofha)

Write-Host "Setting up Shoofha folder structure..." -ForegroundColor Cyan

# ادخل على مجلد lib
Set-Location -Path "lib"

# احذف main.dart الافتراضي
if (Test-Path "main.dart") {
    Remove-Item "main.dart"
}

# قائمة المجلدات اللي بدنا ننشئها
$folders = @(
    "app/router",
    "app/theme",
    "core/responsive",
    "core/localization",
    "features/auth/presentation/screens",
    "features/main_shell/presentation",
    "features/home/presentation/screens",
    "features/explore/presentation/screens",
    "features/offers/presentation/screens",
    "features/cart/presentation/screens",
    "features/profile/presentation/screens",
    "features/store/presentation/screens",
    "features/commerce/presentation/screens",
    "features/social/presentation/screens",
    "features/messaging/presentation/screens",
    "features/settings/presentation/screens",
    "features/merchant/presentation/screens"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Created folder: $folder"
    }
}

# قائمة الملفات الفارغة اللي بدنا نجهزها
$files = @(
    "main.dart",
    "app/router/app_router.dart",
    "app/theme/app_theme.dart",
    "core/responsive/responsive.dart",
    "core/localization/app_localizations.dart",

    # Auth screens
    "features/auth/presentation/screens/splash_screen.dart",
    "features/auth/presentation/screens/welcome_screen.dart",
    "features/auth/presentation/screens/login_screen.dart",
    "features/auth/presentation/screens/signup_screen.dart",
    "features/auth/presentation/screens/otp_screen.dart",
    "features/auth/presentation/screens/choose_interests_screen.dart",

    # Main shell
    "features/main_shell/presentation/main_shell.dart",

    # Main tabs
    "features/home/presentation/screens/home_screen.dart",
    "features/explore/presentation/screens/explore_screen.dart",
    "features/offers/presentation/screens/top_offers_screen.dart",
    "features/cart/presentation/screens/cart_screen.dart",
    "features/profile/presentation/screens/profile_screen.dart",

    # Store & commerce
    "features/store/presentation/screens/store_profile_screen.dart",
    "features/store/presentation/screens/store_products_screen.dart",
    "features/commerce/presentation/screens/product_details_screen.dart",
    "features/commerce/presentation/screens/checkout_screen.dart",
    "features/commerce/presentation/screens/order_success_screen.dart",
    "features/commerce/presentation/screens/my_orders_screen.dart",

    # Social & messaging
    "features/social/presentation/screens/favorites_screen.dart",
    "features/messaging/presentation/screens/messages_inbox_screen.dart",
    "features/messaging/presentation/screens/chat_screen.dart",
    "features/messaging/presentation/screens/notifications_screen.dart",

    # Settings
    "features/settings/presentation/screens/settings_screen.dart",

    # Merchant
    "features/merchant/presentation/screens/merchant_dashboard_screen.dart",
    "features/merchant/presentation/screens/upload_post_screen.dart",
    "features/merchant/presentation/screens/products_management_screen.dart"
)

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
        Write-Host "Created file: $file"
    }
}

Write-Host "Shoofha structure created successfully ✅" -ForegroundColor Green
