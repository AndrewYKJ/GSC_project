import 'package:flutter/material.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/controllers/aurum/aurum_ecombo.dart';
import 'package:gsc_app/controllers/aurum/aurum_showtimes.dart';
import 'package:gsc_app/controllers/cinemas/cinema_list.dart';
import 'package:gsc_app/controllers/cinemas/movie_showtimes_by_locations.dart';
import 'package:gsc_app/controllers/fast_ticket/cinema_name_list.dart';
import 'package:gsc_app/controllers/fast_ticket/fast_ticket.dart';
import 'package:gsc_app/controllers/fast_ticket/movie_name_list.dart';
import 'package:gsc_app/controllers/fnb/fnb.dart';
import 'package:gsc_app/controllers/home/experience_list.dart';
import 'package:gsc_app/controllers/home/home.dart';
import 'package:gsc_app/controllers/login/first_time_login.dart';
import 'package:gsc_app/controllers/login/login.dart';
import 'package:gsc_app/controllers/home/promotion_list.dart';
import 'package:gsc_app/controllers/message_center/message_detail.dart';
import 'package:gsc_app/controllers/message_center/message_list.dart';
import 'package:gsc_app/controllers/movies/movie_details.dart';
import 'package:gsc_app/controllers/movies/movie_list.dart';
import 'package:gsc_app/controllers/movies/movie_select_seat.dart';
import 'package:gsc_app/controllers/my_rewards/my_rewards.dart';
import 'package:gsc_app/controllers/my_rewards/my_rewards_detail.dart';
import 'package:gsc_app/controllers/my_ticket/my_ticket.dart';
import 'package:gsc_app/controllers/my_ticket/my_ticket_details.dart';
import 'package:gsc_app/controllers/my_ticket/ticket_qr.dart';
import 'package:gsc_app/controllers/otp/otp.dart';
import 'package:gsc_app/controllers/password/forgot_password.dart';
import 'package:gsc_app/controllers/password/reset_password.dart';
import 'package:gsc_app/controllers/movies/movie_showtimes_by_opsdate.dart';
import 'package:gsc_app/controllers/profile/add_favourite_screen.dart';
import 'package:gsc_app/controllers/profile/edit_profile.dart';
import 'package:gsc_app/controllers/profile/favourite_list.dart';
import 'package:gsc_app/controllers/profile/profile.dart';
import 'package:gsc_app/controllers/purchase_ticket/confirm_ticket_type.dart';
import 'package:gsc_app/controllers/purchase_ticket/ecombo_selection.dart';
import 'package:gsc_app/controllers/purchase_ticket/payment_gateway.dart';
import 'package:gsc_app/controllers/purchase_ticket/done_transaction.dart';
import 'package:gsc_app/controllers/purchase_ticket/review_summary.dart';
import 'package:gsc_app/controllers/qr_member/qr_member.dart';
import 'package:gsc_app/controllers/rewards_center/rewards_center_details.dart';
import 'package:gsc_app/controllers/rewards_center/rewards_center_listing.dart';
import 'package:gsc_app/controllers/settings/change_password.dart';
import 'package:gsc_app/controllers/settings/delete_account.dart';
import 'package:gsc_app/controllers/settings/settings.dart';
import 'package:gsc_app/controllers/sign_up/sign_up.dart';
import 'package:gsc_app/controllers/tab/homebase.dart';
import 'package:gsc_app/models/arguments/buy_ticket_type_arguments.dart';
import 'package:gsc_app/models/arguments/combo_selection_arguments.dart';
import 'package:gsc_app/models/arguments/init_transaction_arguments.dart';
import 'package:gsc_app/models/arguments/movie_to_buy_arguments.dart';
import 'package:gsc_app/models/arguments/payment_result_arguments.dart';
import 'package:gsc_app/models/json/as_vouchers_model.dart';
import 'package:gsc_app/models/json/cms_experience_model.dart';
import 'package:gsc_app/models/json/cms_promotion_model.dart';
import 'package:gsc_app/models/json/movie_home_model.dart';
import 'package:gsc_app/models/json/movie_showtimes.dart';
import 'package:gsc_app/models/json/rewards_voucher_type_list.dart';
import 'package:gsc_app/models/json/nearby_location_model.dart';

import '../controllers/profile/gsc_coin_transaction.dart';
import '../controllers/splash_screen.dart';
import '../models/arguments/aurum_ecombo_selection_arguments.dart';
import '../models/arguments/custom_seat_selection_arguments.dart';

class AppRoutes {
  static const String splashScreenRoute = "splash_screen";
  static const String movieShowtimesByOpsdate = "movieShowtimeByOps";
  static const String movieShowtimesByCinema = "movieShowtimesByCinema";
  static const String comboSelectionScreen = "comboSelectionScreen";
  static const String movieSeatSelection = "movieSeatSelection";
  static const String reviewSummaryRoute = "reviewSummaryRoute";
  static const String promotionListRoute = "promotionList";
  static const String experienceListRoute = "experienceList";
  static const String homebaseRoute = "homebase";
  static const String homeRoute = "home";
  static const String successPaymentRoute = "successPaymentScreen";
  static const String favouriteCinemaRoute = "favouriteCinemaRoute";
  static const String addFavouriteCinemaRoute = 'addFavouriteCinemaRoute';
  static const String paymentGatewayRoute = "paymentGatewayScreen";
  static const String movieListRoute = "movieList";
  static const String cinemaListRoute = "cinemaList";
  static const String fnbRoute = "fnb";
  static const String profileRoute = "profile";
  static const String movieDetailsRoute = "movieDetails";
  static const String qrMemberRoute = "qrMember";
  static const String signUpRoute = "signUpRoute";
  static const String otpRoute = "otpRoute";
  static const String loginRoute = "loginRoute";
  static const String firstTimeLoginRoute = "firstTimeLoginRoute";
  static const String editProfileRoute = "editProfileRoute";
  static const String gsCoinsTransactionRoute = "gsCoinsTransactionRoute";
  static const String forgotPasswordRoute = "forgotPasswordRoute";
  static const String resetPasswordRoute = "resetPasswordRoute";
  static const String myTicketRoute = "myTicketRoute";
  static const String myTicketQrRoute = "myTicketQrRoute";
  static const String myTicketDetailsRoute = "myTicketDetailsRoute";
  static const String aurumShowtimesRoute = "aurumShowtimesRoute";
  static const String buyMovieTicketTypeRoute = "buyMovieTicketTypeRoute";
  static const String aurumEcomboRoute = "aurumEcomboRoute";
  static const String fastTicketRoute = "fastTicketRoute";
  static const String movieNameListingRoute = "movieNameListingRoute";
  static const String cinemaNameListingRoute = "cinemaNameListingRoute";

  static const String settingsRoute = "settingsRoute";
  static const String settingsChangePasswordRoute =
      "settingsChangePasswordRoute";
  static const String settingsDeleteAccountRoute = "settingsDeleteAccountRoute";
  static const String messageCenterRoute = "messageCenterRoute";
  static const String messageDetailRoute = "messageDetailRoute";
  static const String rewardsCenterListingRoute = "rewardsCenterListingRoute";
  static const String rewardsCenterDetailsRoute = "rewardsCenterDetailsRoute";
  static const String myRewardsRoute = "myRewardsRoute";
  static const String myRewardsDetailRoute = "myRewardsDetailRoute";

  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreenRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case homebaseRoute:
        dynamic args = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => HomeBase(
                  key: HomeBase.homeKey,
                  config: args,
                ));

      case successPaymentRoute:
        TransactionResultArg args = settings.arguments as TransactionResultArg;
        return MaterialPageRoute(
            builder: (_) => CompletePurchase(
                  data: args,
                ));
      case paymentGatewayRoute:
        InitSalesTransactionArg args =
            settings.arguments as InitSalesTransactionArg;
        return MaterialPageRoute(
            builder: (_) => PaymentGateway(
                  data: args,
                ));

      case homeRoute:
        List<dynamic> args = settings.arguments as List;
        bool isLogin = args[0] as bool;
        return MaterialPageRoute(builder: (_) => HomeScreen(isLogin: isLogin));
      case movieShowtimesByOpsdate:
        MovieToBuyArgs arguments = settings.arguments as MovieToBuyArgs;
        return MaterialPageRoute(
          builder: (_) => MovieShowtimesByOpsdate(data: arguments),
        );
      case movieShowtimesByCinema:
        MovieToBuyArgs arguments = settings.arguments as MovieToBuyArgs;
        return MaterialPageRoute(
          builder: (_) => MovieShowtimesByCinema(data: arguments),
        );
      case movieSeatSelection:
        CustomSeatSelectionArg arguments =
            settings.arguments as CustomSeatSelectionArg;
        return MaterialPageRoute(
          builder: (_) => MovieHallSelectSeat(
            data: arguments.selectedShowtimesData,
            title: arguments.title,
            opsdate: arguments.opsdate,
            movieChild: arguments.movieDetails,
            fromWher: arguments.fromWher,
            isAurum: arguments.isAurum,
          ),
        );
      case promotionListRoute:
        List<CMS_PROMOTION> arguments =
            settings.arguments as List<CMS_PROMOTION>;
        return MaterialPageRoute(
            builder: (_) => PromotionList(
                  data: arguments,
                ));
      case editProfileRoute:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case gsCoinsTransactionRoute:
        return MaterialPageRoute(builder: (_) => const CoinTransactionPage());
      case favouriteCinemaRoute:
        return MaterialPageRoute(builder: (_) => const FavouriteCinemaList());
      case addFavouriteCinemaRoute:
        List<SwaggerLocation> arguments =
            settings.arguments as List<SwaggerLocation>;
        return MaterialPageRoute(
            builder: (_) => AddFavouriteCinemaScreen(
                  cinemaData: arguments,
                ));
      case comboSelectionScreen:
        ComboSelectionArguments arguments =
            settings.arguments as ComboSelectionArguments;

        return MaterialPageRoute(
            builder: (_) => EcomboSelectionScreen(
                  data: arguments,
                ));
      case reviewSummaryRoute:
        InitSalesTransactionArg arguments =
            settings.arguments as InitSalesTransactionArg;
        return MaterialPageRoute(
            builder: (_) => ReviewSummaryScreen(data: arguments));
      case experienceListRoute:
        List<CMS_EXPERIENCE> arguments =
            settings.arguments as List<CMS_EXPERIENCE>;
        return MaterialPageRoute(
            builder: (_) => ExperienceList(
                  data: arguments,
                ));
      case movieListRoute:
        return MaterialPageRoute(builder: (_) => const MovieListScreen());
      case cinemaListRoute:
        return MaterialPageRoute(builder: (_) => const CinemaListScreen());
      case fnbRoute:
        bool isPush = settings.arguments as bool;
        return MaterialPageRoute(
            builder: (_) => FnbScreen(
                  isFromPush: isPush,
                ));
      case profileRoute:
        List<dynamic> args = settings.arguments as List;
        bool isLogin = args[0] as bool;
        VoidCallback logout = args[1] as VoidCallback;
        VoidCallback login = args[2] as VoidCallback;

        return MaterialPageRoute(
            builder: (_) => ProfileScreen(
                isLogin: isLogin,
                isLogoutSuccess: logout,
                isLoginSuccess: login));
      case movieDetailsRoute:
        List<dynamic> args = settings.arguments as List;
        String code = args[0] as String;
        bool isAurum = args[1] as bool;
        bool fromMoviePopup = args[2] as bool;
        return MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(
                parentCode: code,
                isAurum: isAurum,
                fromMoviePopup: fromMoviePopup));
      case qrMemberRoute:
        List<dynamic> args = settings.arguments as List;
        bool fromProfile = args[0] as bool;
        return MaterialPageRoute(
            builder: (_) => QrMemberScreen(
                  isFromProfile: fromProfile,
                ),
            fullscreenDialog: true);
      case signUpRoute:
        return MaterialPageRoute(
            builder: (_) => const SignUpScreen(), fullscreenDialog: true);
      case otpRoute:
        return MaterialPageRoute(
            builder: (_) => OtpScreen(
                  code: "",
                  number: "",
                  type: Constants.OTP_FORGET,
                ));
      case loginRoute:
        return MaterialPageRoute(
            builder: (_) => const LoginScreen(), fullscreenDialog: true);
      case firstTimeLoginRoute:
        String arguments = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => FirstTimeLoginScreen(mobile: arguments));
      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPasswordRoute:
        List<dynamic> args = settings.arguments as List;
        String mobile = args[0] as String;
        return MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
                  mobile: mobile,
                ));
      case myTicketRoute:
        return MaterialPageRoute(builder: (_) => const MyTicketScreen());
      case myTicketQrRoute:
        List<dynamic> args = settings.arguments as List;
        String id = args[0] as String;
        String qrId = args[1] as String;
        return MaterialPageRoute(
            builder: (_) => TicketQrScreen(id: id, qrID: qrId));
      case myTicketDetailsRoute:
        List<dynamic> args = settings.arguments as List;
        String url = args[0] as String;
        return MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(url: url),
        );
      case aurumShowtimesRoute:
        return MaterialPageRoute(builder: (_) => const AurumShowtimesScreen());
      case buyMovieTicketTypeRoute:
        BuyTicketTypeArgs arguments = settings.arguments as BuyTicketTypeArgs;
        return MaterialPageRoute(
          builder: (_) => ConfirmTicketTypeScreen(data: arguments),
        );
      case aurumEcomboRoute:
        AurumEComboArgs arguments = settings.arguments as AurumEComboArgs;
        return MaterialPageRoute(builder: (_) => AurumEcombo(data: arguments));
      case fastTicketRoute:
        return MaterialPageRoute(
          builder: (_) => const FastTicketScreen(),
        );
      case movieNameListingRoute:
        List<dynamic> args = settings.arguments as List;
        List<Parent> movieList = args[0] as List<Parent>;
        Parent recommendedMovie = args[1] as Parent;
        return MaterialPageRoute(
          builder: (_) => MovieNameListScreen(
            movieList: movieList,
            recommendedMovie: recommendedMovie,
          ),
        );
      case cinemaNameListingRoute:
        List<dynamic> args = settings.arguments as List;
        List<Location> locationList = args[0] as List<Location>;
        Location recommendedCinema = args[1] as Location;
        List<Location> favouriteLocationIdList = args[2] as List<Location>;
        return MaterialPageRoute(
          builder: (_) => CinemaNameListScreen(
              locationList: locationList,
              recommendedCinema: recommendedCinema,
              favList: favouriteLocationIdList),
        );
      case settingsRoute:
        VoidCallback logout = settings.arguments as VoidCallback;
        return MaterialPageRoute(
          builder: (_) => SettingScreen(
            isLogoutSuccess: logout,
          ),
        );
      case settingsChangePasswordRoute:
        VoidCallback logout = settings.arguments as VoidCallback;
        return MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(
            isLogoutSuccess: logout,
          ),
        );
      case settingsDeleteAccountRoute:
        return MaterialPageRoute(
          builder: (_) => const DeleteAccountScreen(),
        );
      case messageCenterRoute:
        return MaterialPageRoute(
          builder: (_) => const MessageListScreen(),
        );
      case messageDetailRoute:
        List<dynamic> args = settings.arguments as List;
        String blastID = args[0] as String;
        String uuid = args[1] as String;
        return MaterialPageRoute(
          builder: (_) => MessageDetailScreen(
            blastHeaderId: blastID,
            deviceUUID: uuid,
          ),
        );
      case rewardsCenterListingRoute:
        return MaterialPageRoute(builder: (_) => const RewardsCenterListing());
      case rewardsCenterDetailsRoute:
        RewardsVoucherTypeList args =
            settings.arguments as RewardsVoucherTypeList;
        return MaterialPageRoute(
            builder: (_) => RewardsCenterDetails(details: args));
      case myRewardsRoute:
        List<RewardsVoucherTypeList> args =
            settings.arguments as List<RewardsVoucherTypeList>;
        return MaterialPageRoute(
          builder: (_) => MyRewardsScreen(fullRewardList: args),
        );
      case myRewardsDetailRoute:
        List<dynamic> args = settings.arguments as List;
        VoucherItemDTO voucher = args[0] as VoucherItemDTO;
        bool isPast = args[1] as bool;

        return MaterialPageRoute(
          builder: (_) =>
              MyRewardDetailScreen(voucherItemDTO: voucher, isPast: isPast),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeBase());
    }
  }
}
