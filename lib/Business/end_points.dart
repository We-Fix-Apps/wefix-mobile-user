class EndPoints {
  static String baseUrl = 'https://api.wefixjo.com/';
  // static String baseUrl = 'https://apitestwefix.oneit.website/';
  // static String baseUrl = 'https://wefixapi.oneit.website/';

  // * Authantication
  static String signUp = 'users/Signup';
  static String resetPassword = '';
  static String checkOtp = 'users/SendOtpCustomer';
  static String home = 'Common/Home';
  static String subCategory = 'Common/ServiceByCategory/';
  static String transactions = 'Customer/Transactions';
  static String createTransactions = 'Customer/CreateTransactions';
  static String notifications = 'Customer/Notification';
  static String contractDetails = 'Customer/MyContract';
  static String createOrder = 'Customer/ServiceRequest';
  static String booking = 'customer/Tickets';
  static String packages = 'customer/Packages/';
  static String questions = 'customer/Questions';
  static String contactInfo = 'Common/ContactInfo';
  static String contactUs = 'Common/ContatcForm';
  static String cancleBooking = 'customer/CancelTickets';
  static String bookingDetails = 'ServiceProvider/Tickets/';
  static String createRealState = 'customer/CreateRealEstate';
  static String editRealState = 'customer/EditRealEstate';
  static String isSubsicribe = 'Customer/IsSubscribe';
  static String subscribe = 'Customer/Subscribe';
  static String rate = 'Customer/CreateReview';
  static String renew = 'customer/RenewSubscribe';
  static String activeTickets = 'Common/ActiveTickets';
  static String buissnessType = 'Common/BusinessType';

  static String calculateSubPrice = 'customer/Calculate';
  static String getRealState = 'customer/RealEstate';
  static String addReview = 'customer/CreateCustomerQuestions';
  static String checkAvilabel = 'customer/CheckAvilabel';
  static String holiday = 'Customer/Holiday';
  static String appoitmentTime = 'customer/CheckAvilabelTime';
  static String chat = 'webhook/push';
  static String messages = 'users/Getallmsg/';
  static String advantages = 'customer/Advantage';

  // * Shop
  static String shop = 'seller/getall';
  static String shopDeatils = 'seller/Getbyid/';
  static String brands = 'Common/Brands';
  static String review = 'Seller/ReviewsList';
  static String createChat = 'Inbox/createchat/';
  static String messagesList = 'Inbox/messagelist';
  static String contactlist = 'Inbox/contactlist';
  static String sendMessage = 'Inbox/sendmessage';
  static String updateMessage = 'Inbox/inboxmessageupdate/';

  static String login = 'Users/login';
  // * Bannar
  static String bannar = 'Common/slider';
  static String splashScreen = 'Common/seblashscreen';
  // * Category
  static String category = 'Common/Category/0';
  static String color = 'Common/getcolor';

  // * Products
  static String allProducts = 'Product/getdiscount/';
  static String getFeatuered = 'Product/getFeatured';

  static String allProductsBySeller = 'Seller/GetProductBysellerid/';
  static String allProductByBrand = 'Product/getbybrand/';

  static String productsByCategory = 'Product/getbycategory/';
  static String productsById = 'Product/getbyid/';
  static String searchProducts = 'Product/getall/';
  static String productQuestion = 'Product/ProductQuestions/';
  static String getpopular = 'Product/GetPopular';
  static String getSearchLast = 'Product/GetSavedSearch';

  static String addToWishlist = 'Product/addtowishlist';
  static String addToCart = 'Order/AddToCart';
  static String removeFromCart = 'Order/DeleteCartItem';
  static String updateCart = 'Order/UpdateToCart';
  static String checkOut = 'Order/CheckOut';
  static String promoCode = 'customer/GetPromo';

  static String cart = 'Order/ShowCart';

  static String askQuestion = 'Product/AskQuestion';

  static String removeFromWishlist = 'Product/removetowishlist';

  // * Ask qeuestion
  static String askQuestions = '';

  static String orders = 'Order/OrdersList';
  static String ordersDetails = 'Order/GetByInvoice/';

  // * profile

  static String wishlist = 'Product/wishlist';
  static String address = 'Customer/Address';
  static String addAddress = 'Customer/CreateAddress';
  static String getShippingInfo = 'Order/GetShippingInfo';
  static String getProfile = 'user/profile';
  static String editProfile = 'user/UpdateProfile';
  static String changedPassword = 'user/changepassword';
  static String changedPhone = 'user/editphone';
  static String deleteAccount = 'user/deleteAccount';

  static String editAddress = 'UserAddress/edit';
  static String removeAddress = 'UserAddress/Delete';
  static String cancelOrder = 'order/CancelOrder';

  static String coupons = '';
  static String forgetPassword = 'Users/forgetpassword';

  static String about = 'customer/About';
  static String privacy = 'Common/Pages/privacy-policy';
  static String terms = 'Common/Pages/terms-and-conditions';
  static String lang = 'common/Languages';
  static String langCode = 'common/AppLanguages';
  static String facebook = 'user/HideGoogleAndFaceBook';

  // * B2B

  static String createBranch = 'customer/Branch';
  static String getAllBranch = 'customer/GetAllBranch';
  static String isSubscribeCompany = 'customer/IsSubscribeCompany';
  static String serviceCompany = 'customer/ServiceCompany';

  // * MMS API (Backend MMS)
  static String mmsBaseUrl = 'https://wefix-backend-mms.ngrok.app/api/v1/'; // Update with your backend URL
  static String mmsLogin = 'users/login';
  static String mmsLogout = 'users/logout';
  static String mmsRefreshToken = 'users/refresh-token';
  static String mmsRegister = 'users/register';
  static String mmsTickets = 'tickets';
  static String mmsTicketStatistics = 'tickets/statistics';
  static String mmsTicketDetails = 'tickets/'; // Append ticket ID
  static String mmsCreateTicket = 'tickets';
  static String mmsUpdateTicket = 'tickets/'; // Append ticket ID
  static String mmsCompanyContracts = 'company-data/contracts';
  static String mmsCompanyBranches = 'company-data/branches';
  static String mmsCompanyZones = 'company-data/zones';
  static String mmsMainServices = 'company-data/main-services';
  static String mmsSubServices = 'company-data/sub-services';
  static String mmsCompanyTeamLeaders = 'company-data/team-leaders';
  static String mmsCompanyTechnicians = 'company-data/technicians';
  static String mmsTicketTypes = 'company-data/ticket-types';
  static String mmsTicketStatuses = 'company-data/ticket-statuses';
  static String mmsUploadFiles = 'files/upload-multiple'; // New - Upload multiple files
}
