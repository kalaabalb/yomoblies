import 'package:e_commerce_flutter/utility/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/category.dart';
import '../../models/api_response.dart';
import '../../models/brand.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../services/http_services.dart';
import '../../utility/constants.dart';
import '../../utility/snack_bar_helper.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];
  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isCategoriesLoading = true;
  bool get isCategoriesLoading => _isCategoriesLoading;

  bool _isProductsLoading = true;
  bool get isProductsLoading => _isProductsLoading;

  bool _isPostersLoading = true;
  bool get isPostersLoading => _isPostersLoading;

  // Complete translation maps with all languages
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'welcome': 'Hello',
      'welcome_back': 'Welcome back!',
      'user': 'User',
      'get_something': 'Let\'s get something!',
      'get_now': 'Get Now',
      'about': 'About',
      'enter_username': 'Enter username',
      'enter_password': 'Enter password',
      'confirm_password': 'Confirm password',
      'passwords_dont_match': 'Passwords do not match',
      'login': 'Login',
      'register': 'Register',
      'dont_have_account': 'Don\'t have an account? Register',
      'already_have_account': 'Already have an account? Login',
      'total_amount': 'Total Amount',
      'discount': 'Discount',
      'grand_total': 'Grand Total',
      'apply': 'Apply',
      'complete_order': 'Complete Order',
      'buy_now': 'Buy Now',
      'enter_address': 'Enter Address',
      'payment_method': 'Payment Method',
      'sort_by_price': 'Sort By Price',
      'low_to_high': 'Low To High',
      'high_to_low': 'High To Low',
      'filter_by_brands': 'Filter By Brands',
      'available_stock': 'Available stock',
      'not_available': 'Not available',
      'add_to_cart': 'Add to cart',
      'no_favorite_items': 'No favorite items yet',
      'empty_cart': 'Empty cart',
      'my_account': 'My Account',
      'my_profile': 'My Profile',
      'my_orders': 'My Orders',
      'my_address': 'My Address',
      'my_favorites': 'My Favorites',
      'my_cart': 'My Cart',
      'member_since': 'Member since',
      'username': 'Username',
      'notifications': 'Notifications',
      'privacy_security': 'Privacy & Security',
      'about_app': 'About App',
      'help_support': 'Help & Support',
      'email_support': 'Email Support',
      'call_support': 'Call Support',
      'live_chat': 'Live Chat',
      'close': 'Close',
      'logout': 'Logout',
      'logout_confirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'update_address': 'Update Address',
      'phone': 'Phone',
      'street': 'Street',
      'city': 'City',
      'state': 'State',
      'postal_code': 'Postal Code',
      'country': 'Country',
      'please_enter_phone': 'Please enter a phone number',
      'please_enter_street': 'Please enter a street',
      'please_enter_city': 'Please enter a city',
      'please_enter_state': 'Please enter a state',
      'please_enter_code': 'Please enter a code',
      'please_enter_country': 'Please enter a country',
      'home': 'Home',
      'favorites': 'Favorites',
      'cart': 'Cart',
      'profile': 'Profile',
      'settings': 'SETTINGS',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'select_language': 'Select Language',
      'help': 'HELP & SUPPORT',
      'total': 'Total',
      'payment_successful': 'Payment Successful!',
      'payment_failed': 'Payment failed',
      'order_created': 'Order created successfully!',
      'address_stored': 'Address stored successfully',
      'item_added_to_cart': 'Item added to cart',
      'please_select_variant': 'Please select a variant',
      'search_hint': 'Search...',
      'available': 'Available',
      'options': 'Options',
      'please_fill_all_fields': 'Please fill all fields',
      'error': 'Error',
      'top_categories': 'Top Categories',
      'success': 'Success',
      'loading': 'Loading...',
      'track_order': 'Track Order',
      'discover_products': 'Discover Amazing Products',
      'easy_shopping': 'Easy & Secure Shopping',
      'fast_delivery': 'Fast Delivery',
      'start_shopping': 'Start Shopping Now!',
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'customer_reviews': 'Customer Reviews',
      'change_password': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'profile_change_note':
          'Note: Changing email will require verification. Changing username/password will log you out.',
      'email_not_verified': 'Email not verified',

      'cart_empty_message': 'Your cart is empty',
      'subtotal': 'Subtotal',
      'item_removed': 'Item removed from cart',
      'item_added': 'Item added to cart',
      'cart_updated': 'Cart updated',

      // Payment Methods
      'cash_on_delivery': 'Cash on Delivery',
      'cbe_bank': 'Commercial Bank of Ethiopia',
      'telebirr': 'Telebirr',

      // Order Status
      'order_processing': 'Processing',
      'order_shipped': 'Shipped',
      'order_delivered': 'Delivered',
      'order_cancelled': 'Cancelled',

      // Buttons & Actions
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'continue_shopping': 'Continue Shopping',
      'view_orders': 'View Orders',
      'reviews': 'Reviews',
      'review': 'Review',
      'load_more_reviews': 'Load More Reviews',
      'no_reviews_yet': 'No reviews yet. Be the first to review this product!',
      'anonymous': 'Anonymous',
      'verified_purchase': 'Verified Purchase',
      'rate_this_product': 'Rate this product',
      'your_rating': 'Your Rating',

      'delete_rating': 'Delete Rating',
      'delete_rating_confirmation':
          'Are you sure you want to delete your rating?',
      'submit': 'Submit',
      'update': 'Update',
      'review_optional': 'Review (optional)',
    },
    'am': {
      'welcome': 'ሰላም',
      'customer_reviews': 'የደንበኞች አስተያየቶች',
      'reviews': 'አስተያየቶች',
      'review': 'አስተያየት',
      'load_more_reviews': 'ተጨማሪ አስተያየቶችን አስገባ',
      'no_reviews_yet': 'እስካሁን አስተያየት የለም። ይህን ምርት ለመገምገም የመጀመሪያው ይሁኑ!',
      'anonymous': 'ስም የለሽ',
      'verified_purchase': 'የተረጋገጠ ግዢ',
      'rate_this_product': 'ይህን ምርት ደረጃ ይስጡ',
      'your_rating': 'የእርስዎ ደረጃ',
      'edit': 'አርትዕ',
      'delete': 'ሰርዝ',
      'delete_rating': 'ደረጃ ሰርዝ',
      'delete_rating_confirmation': 'ደረጃዎን ለማስወገድ እርግጠኛ ነዎት?',
      'submit': 'አስገባ',
      'update': 'አዘምን',
      'cancel': 'ተው',
      'review_optional': 'አስተያየት (አማራጭ)',
      'welcome_back': 'እንኳን ደህና መጡ!',
      'user': 'ተጠቃሚ',
      'get_something': 'አንድ ነገር እንፈልግ!',
      'get_now': 'አሁን ያግኙ',
      'about': 'ስለ',
      'change_password': 'የይለፍ ቃል ይቀይሩ',
      'current_password': 'አሁን ያለው የይለፍ ቃል',
      'new_password': 'አዲስ የይለፍ ቃል',
      'confirm_new_password': 'አዲሱን የይለፍ ቃል ያረጋግጡ',
      'profile_change_note':
          'ማስታወሻ: ኢሜይል ለመቀየር ማረጋገጫ ያስፈልጋል። የተጠቃሚ ስም/የይለፍ ቃል ለመቀየር ይወጣሉ።',
      'email_not_verified': 'ኢሜይል አልተረጋገጠም',
      'member_since': 'አባል ከ',

      // Product Details
      'product_details': 'የምርት ዝርዝሮች',
      'available_stock': 'የሚገኝ ክምችት',
      'not_available': 'አይገኝም',
      'available_options': 'የሚገኙ ምርጫዎች',

      // Cart & Checkout
      'empty_cart': 'ባዶ ጋሪ',
      'cart_empty_message': 'ጋሪዎ ባዶ ነው',
      'subtotal': 'ንዑስ ድምር',
      'item_removed': 'ነገር ከጋሪ ተወግዷል',
      'item_added': 'ነገር ወደ ጋሪ ታክሏል',
      'cart_updated': 'ጋሪ ተዘምኗል',

      // Payment Methods
      'cash_on_delivery': 'በመላክ ክፍያ',
      'cbe_bank': 'የንግድ ባንክ ኢትዮጵያ',
      'telebirr': 'ቴሌብር',

      // Order Status
      'order_processing': 'በሂደት ላይ',
      'order_shipped': 'ተልኳል',
      'order_delivered': 'ደርሷል',
      'order_cancelled': 'ተሰርዟል',

      'save': 'አስቀምጥ',

      'confirm': 'አረጋግጥ',
      'continue_shopping': 'ግዢ ቀጥል',
      'view_orders': 'ትዕዛዞችን ይመልከቱ',
      'enter_username': 'የተጠቃሚ ስም ያስገቡ',
      'enter_password': 'የይለፍ ቃል ያስገቡ',
      'confirm_password': 'የይለፍ ቃል ያረጋግጡ',
      'passwords_dont_match': 'የይለፍ ቃሎች አይዛመዱም',
      'login': 'ግባ',
      'register': 'ተመዝገብ',
      'dont_have_account': 'መለያ የሎትም? ይመዝገቡ',
      'already_have_account': 'ቀድሞ መለያ አለዎት? ይግቡ',
      'total_amount': 'ጠቅላላ ዋጋ',
      'discount': 'ቅናሽ',
      'grand_total': 'ጠቅላላ ድምር',
      'apply': 'አስገባ',
      'complete_order': 'ትዕዛዝ አጠናቅቅ',
      'buy_now': 'አሁን ግዛ',
      'enter_address': 'አድራሻ ያስገቡ',
      'payment_method': 'የመክፈያ ዘዴ',
      'sort_by_price': 'በዋጋ ያስቀምጡ',
      'low_to_high': 'ከዝቅ ወደ ከፍታ',
      'high_to_low': 'ከከፍታ ወደ ዝቅታ',
      'filter_by_brands': 'በምርት ስም አጣራ',

      'add_to_cart': 'ወደ ጋሪ ጨምር',
      'no_favorite_items': 'እስካሁን የሚወዷቸው ነገሮች የሉም',
      'my_account': 'መለያዬ',
      'my_profile': 'መለያዬ',
      'my_orders': 'ትዕዛዞቼ',
      'my_address': 'አድራሻዬ',
      'my_favorites': 'የሚወዷቸው',
      'my_cart': 'ጋሪዬ',
      'username': 'የተጠቃሚ ስም',
      'notifications': 'ማሳወቂያዎች',
      'privacy_security': 'ግላዊነት እና ደህንነት',
      'about_app': 'ስለ መተግበሪያው',
      'help_support': 'እገዛ እና ድጋፍ',
      'email_support': 'ኢሜይል ድጋፍ',
      'call_support': 'የስልክ ድጋፍ',
      'live_chat': 'ቀጥታ ውይይት',
      'close': 'ዝጋ',
      'logout': 'ውጣ',
      'logout_confirmation': 'ከመተግበሪያው መውጣት እፈልጋለሁ?',
      'update_address': 'አድራሻ አዘምን',
      'phone': 'ስልክ',
      'street': 'ጎዳና',
      'city': 'ከተማ',
      'state': 'ክልል',
      'postal_code': 'ፖስታ ኮድ',
      'country': 'አገር',
      'please_enter_phone': 'እባክዎ ስልክ ቁጥር ያስገቡ',
      'please_enter_street': 'እባክዎ ጎዳና ያስገቡ',
      'please_enter_city': 'እባክዎ ከተማ ያስገቡ',
      'please_enter_state': 'እባክዎ ክልል ያስገቡ',
      'please_enter_code': 'እባክዎ ኮድ ያስገቡ',
      'please_enter_country': 'እባክዎ አገር ያስገቡ',
      'home': 'መነሻ',
      'favorites': 'የሚወዷቸው',
      'cart': 'ጋሪ',
      'profile': 'መለያ',
      'settings': 'ማስተካከያዎች',
      'dark_mode': 'ጨለማ ሞድ',
      'language': 'ቋንቋ',
      'select_language': 'ቋንቋ ይምረጡ',
      'help': 'እገዛ',
      'total': 'ጠቅላላ',
      'payment_successful': 'ክፍያ በተሳካ ሁኔታ!',
      'payment_failed': 'ክፍያ አልተሳካም',
      'order_created': 'ትዕዛዝ በተሳካ ሁኔታ ተፈጥሯል!',
      'address_stored': 'አድራሻ በተሳካ ሁኔታ ተቀምጧል',
      'item_added_to_cart': 'ነገር ወደ ጋሪ ታክሏል',
      'please_select_variant': 'እባክዎ ልዩነት ይምረጡ',
      'search_hint': 'ፈልግ...',
      'available': 'የሚገኝ',
      'options': 'ልዩነቶች',
      'please_fill_all_fields': 'እባክዎ ሁሉንም ሕዋሶች ይሙሉ',
      'error': 'ስህተት',
      'top_categories': 'ዋና ዋና ምድቦች',
      'success': 'በተሳካ ሁኔታ',
      'loading': 'በማቅረብ ላይ...',
      'track_order': 'ትዕዛዝ ይከታተሉ',
      'discover_products': 'አስደናቂ ምርቶችን ይፈልጉ',
      'easy_shopping': 'ቀላል እና ደህንነቱ የተጠበቀ ግዢ',
      'fast_delivery': 'ፈጣን አቅርቦት',
      'start_shopping': 'አሁን ይግዙ!',
      'skip': 'ዝለል',
      'next': 'ቀጣይ',
      'get_started': 'ጀምር',
    },
    'es': {
      'welcome': 'Hola',
      'welcome_back': '¡Bienvenido de nuevo!',
      'user': 'Usuario',
      'get_something': '¡Vamos a buscar algo!',
      'customer_reviews': 'Opiniones de Clientes',
      'reviews': 'Opiniones',
      'review': 'Opinión',
      'load_more_reviews': 'Cargar Más Opiniones',
      'change_password': 'Cambiar Contraseña',
      'current_password': 'Contraseña Actual',
      'new_password': 'Nueva Contraseña',
      'confirm_new_password': 'Confirmar Nueva Contraseña',
      'profile_change_note':
          'Nota: Cambiar el correo requerirá verificación. Cambiar nombre de usuario/contraseña cerrará su sesión.',
      'email_not_verified': 'Correo no verificado',
      'member_since': 'Miembro desde',

      // Product Details
      'product_details': 'Detalles del Producto',
      'available_stock': 'Stock disponible',
      'not_available': 'No disponible',
      'available_options': 'Opciones disponibles',
      'about': 'Acerca de',

      // Cart & Checkout
      'empty_cart': 'Carrito Vacío',
      'cart_empty_message': 'Tu carrito está vacío',
      'subtotal': 'Subtotal',
      'item_removed': 'Artículo removido del carrito',
      'item_added': 'Artículo agregado al carrito',
      'cart_updated': 'Carrito actualizado',

      // Payment Methods
      'cash_on_delivery': 'Pago contra Entrega',
      'cbe_bank': 'Banco Comercial de Etiopía',
      'telebirr': 'Telebirr',

      // Order Status
      'order_processing': 'Procesando',
      'order_shipped': 'Enviado',
      'order_delivered': 'Entregado',
      'order_cancelled': 'Cancelado',

      // Buttons & Actions
      'save': 'Guardar',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'confirm': 'Confirmar',
      'continue_shopping': 'Continuar Comprando',
      'view_orders': 'Ver Pedidos',
      'no_reviews_yet':
          'Aún no hay opiniones. ¡Sé el primero en opinar sobre este producto!',
      'anonymous': 'Anónimo',
      'verified_purchase': 'Compra Verificada',
      'rate_this_product': 'Calificar este producto',
      'your_rating': 'Tu Calificación',

      'delete_rating': 'Eliminar Calificación',
      'delete_rating_confirmation':
          '¿Estás seguro de que quieres eliminar tu calificación?',
      'submit': 'Enviar',
      'update': 'Actualizar',
      'cancel': 'Cancelar',
      'review_optional': 'Opinión (opcional)',
      'get_now': 'Obtener Ahora',
      'enter_username': 'Ingrese nombre de usuario',
      'enter_password': 'Ingrese contraseña',
      'confirm_password': 'Confirmar contraseña',
      'passwords_dont_match': 'Las contraseñas no coinciden',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'dont_have_account': '¿No tienes una cuenta? Regístrate',
      'already_have_account': '¿Ya tienes una cuenta? Inicia Sesión',
      'total_amount': 'Monto Total',
      'discount': 'Descuento',
      'grand_total': 'Total General',
      'apply': 'Aplicar',
      'complete_order': 'Completar Pedido',
      'buy_now': 'Comprar Ahora',
      'enter_address': 'Ingresar Dirección',
      'payment_method': 'Método de Pago',
      'sort_by_price': 'Ordenar por Precio',
      'low_to_high': 'Menor a Mayor',
      'high_to_low': 'Mayor a Menor',
      'filter_by_brands': 'Filtrar por Marcas',

      'add_to_cart': 'Agregar al carrito',
      'no_favorite_items': 'Aún no hay favoritos',
      'my_account': 'Mi Cuenta',
      'my_profile': 'Mi Perfil',
      'my_orders': 'Mis Pedidos',
      'my_address': 'Mi Dirección',
      'my_favorites': 'Mis Favoritos',
      'my_cart': 'Mi Carrito',
      'username': 'Nombre de usuario',
      'notifications': 'Notificaciones',
      'privacy_security': 'Privacidad y Seguridad',
      'about_app': 'Acerca de la App',
      'help_support': 'Ayuda y Soporte',
      'email_support': 'Soporte por Email',
      'call_support': 'Soporte por Teléfono',
      'live_chat': 'Chat en Vivo',
      'close': 'Cerrar',
      'logout': 'Cerrar Sesión',
      'logout_confirmation': '¿Estás seguro de que quieres cerrar sesión?',
      'update_address': 'Actualizar Dirección',
      'phone': 'Teléfono',
      'street': 'Calle',
      'city': 'Ciudad',
      'state': 'Estado',
      'postal_code': 'Código Postal',
      'country': 'País',
      'please_enter_phone': 'Por favor ingrese un número de teléfono',
      'please_enter_street': 'Por favor ingrese una calle',
      'please_enter_city': 'Por favor ingrese una ciudad',
      'please_enter_state': 'Por favor ingrese un estado',
      'please_enter_code': 'Por favor ingrese un código',
      'please_enter_country': 'Por favor ingrese un país',
      'home': 'Inicio',
      'favorites': 'Favoritos',
      'cart': 'Carrito',
      'profile': 'Perfil',
      'settings': 'AJUSTES',
      'dark_mode': 'Modo Oscuro',
      'language': 'Idioma',
      'select_language': 'Seleccionar Idioma',
      'help': 'AYUDA Y SOPORTE',
      'total': 'Total',
      'payment_successful': '¡Pago Exitoso!',
      'payment_failed': 'Pago fallido',
      'order_created': '¡Pedido creado exitosamente!',
      'address_stored': 'Dirección guardada exitosamente',
      'item_added_to_cart': 'Artículo agregado al carrito',
      'please_select_variant': 'Por favor seleccione una variante',
      'search_hint': 'Buscar...',
      'available': 'Disponible',
      'options': 'Opciones',
      'please_fill_all_fields': 'Por favor complete todos los campos',
      'error': 'Error',
      'top_categories': 'Categorías principales',
      'success': 'Éxito',
      'loading': 'Cargando...',
      'track_order': 'Seguir Pedido',
      'discover_products': 'Descubre Productos Increíbles',
      'easy_shopping': 'Compras Fáciles y Seguras',
      'fast_delivery': 'Entrega Rápida',
      'start_shopping': '¡Comienza a Comprar Ahora!',
      'skip': 'Saltar',
      'next': 'Siguiente',
      'get_started': 'Comenzar',
    },
    'fr': {
      'welcome': 'Bonjour',
      'welcome_back': 'Bon retour!',
      'user': 'Utilisateur',
      'get_something': 'Allons chercher quelque chose!',
      'get_now': 'Obtenir Maintenant',
      'about': 'À propos',
      'enter_username': 'Entrez le nom d\'utilisateur',
      'enter_password': 'Entrez le mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'passwords_dont_match': 'Les mots de passe ne correspondent pas',
      'login': 'Connexion',
      'register': 'S\'inscrire',
      'dont_have_account': 'Vous n\'avez pas de compte? Inscrivez-vous',
      'already_have_account': 'Vous avez déjà un compte? Connectez-vous',
      'total_amount': 'Montant Total',
      'discount': 'Remise',
      'grand_total': 'Total Général',
      'apply': 'Appliquer',
      'complete_order': 'Terminer la Commande',
      'buy_now': 'Acheter Maintenant',
      'enter_address': 'Entrer l\'Adresse',
      'payment_method': 'Méthode de Paiement',
      'sort_by_price': 'Trier par Prix',
      'low_to_high': 'Bas à Haut',
      'high_to_low': 'Haut à Bas',
      'filter_by_brands': 'Filtrer par Marques',
      'available_stock': 'Stock disponible',
      'not_available': 'Non disponible',
      'add_to_cart': 'Ajouter au panier',
      'no_favorite_items': 'Aucun favori pour le moment',
      'empty_cart': 'Panier vide',
      'my_account': 'Mon Compte',
      'my_profile': 'Mon Profil',
      'my_orders': 'Mes Commandes',
      'my_address': 'Mon Adresse',
      'my_favorites': 'Mes Favoris',
      'my_cart': 'Mon Panier',
      'member_since': 'Membre depuis',
      'username': 'Nom d\'utilisateur',
      'notifications': 'Notifications',
      'privacy_security': 'Confidentialité et Sécurité',
      'about_app': 'À propos de l\'App',
      'help_support': 'Aide et Support',
      'email_support': 'Support Email',
      'call_support': 'Support Téléphonique',
      'live_chat': 'Chat en Direct',
      'close': 'Fermer',
      'logout': 'Déconnexion',
      'logout_confirmation': 'Êtes-vous sûr de vouloir vous déconnecter?',
      'cancel': 'Annuler',
      'update_address': 'Mettre à jour l\'Adresse',
      'phone': 'Téléphone',
      'street': 'Rue',
      'city': 'Ville',
      'state': 'État',
      'postal_code': 'Code Postal',
      'country': 'Pays',
      'please_enter_phone': 'Veuillez entrer un numéro de téléphone',
      'please_enter_street': 'Veuillez entrer une rue',
      'please_enter_city': 'Veuillez entrer une ville',
      'please_enter_state': 'Veuillez entrer un état',
      'please_enter_code': 'Veuillez entrer un code',
      'please_enter_country': 'Veuillez entrer un pays',
      'home': 'Accueil',
      'favorites': 'Favoris',
      'cart': 'Panier',
      'profile': 'Profil',
      'settings': 'PARAMÈTRES',
      'dark_mode': 'Mode Sombre',
      'language': 'Langue',
      'select_language': 'Sélectionner la Langue',
      'help': 'AIDE ET SUPPORT',
      'total': 'Total',
      'payment_successful': 'Paiement Réussi!',
      'payment_failed': 'Paiement échoué',
      'order_created': 'Commande créée avec succès!',
      'address_stored': 'Adresse enregistrée avec succès',
      'item_added_to_cart': 'Article ajouté au panier',
      'please_select_variant': 'Veuillez sélectionner une variante',
      'search_hint': 'Rechercher...',
      'available': 'Disponible',
      'options': 'Options',
      'please_fill_all_fields': 'Veuillez remplir tous les champs',
      'error': 'Erreur',
      'top_categories': 'Catégories principales',
      'success': 'Succès',
      'loading': 'Chargement...',
      'track_order': 'Suivre la Commande',
      'discover_products': 'Découvrez des Produits Incroyables',
      'easy_shopping': 'Achats Faciles et Sécurisés',
      'fast_delivery': 'Livraison Rapide',
      'start_shopping': 'Commencez à Magasiner Maintenant!',
      'skip': 'Passer',
      'next': 'Suivant',
      'get_started': 'Commencer',
    },
  };

  String translate(String key) {
    final currentLangTranslations = _translations[_currentLanguage];

    if (currentLangTranslations == null) {
      final englishTranslations = _translations['en'];
      return englishTranslations?[key] ?? key;
    }

    return currentLangTranslations[key] ?? _translations['en']?[key] ?? key;
  }

  String safeTranslate(String key, {String? fallback}) {
    try {
      final translation = translate(key);
      if (translation == key && fallback != null) {
        return fallback;
      }
      return translation;
    } catch (e) {
      return fallback ?? key;
    }
  }

  DataProvider() {
    _loadPreferences();
    _initializeData();
  }

  void _initializeData() async {
    _isLoading = true;
    notifyListeners();

    bool isConnected = await NetworkUtils.checkServerConnection(MAIN_URL);

    if (isConnected) {
      await Future.wait([
        getAllCategory(),
        getAllSubCategory(),
        getAllBrands(),
        getAllProduct(),
        getAllPosters(),
        // call orders too so user orders are available early
        getAllOrders(),
      ]);
    } else {}

    _isLoading = false;
    notifyListeners();
  }

  void _loadPreferences() {
    try {
      _isDarkMode = box.read('isDarkMode') ?? false;
      _currentLanguage = box.read('language')?.toString() ?? 'en';

      if (!_translations.containsKey(_currentLanguage)) {
        _currentLanguage = 'en';
      }
    } catch (e) {
      _isDarkMode = false;
      _currentLanguage = 'en';
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    box.write('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      box.write('language', languageCode);

      // Force immediate rebuild
      notifyListeners();

      // Additional rebuilds to ensure everything updates
      Future.delayed(const Duration(milliseconds: 50), () {
        notifyListeners();
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    }
  }

  // Fix image URLs to use your IP instead of localhost
  // Add this method to fix image URLs
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Replace all possible localhost variations with your server IP
    return url
        .replaceAll('http://localhost:3000', 'http://10.161.175.199:3000')
        .replaceAll('http://127.0.0.1:3000', 'http://10.161.175.199:3000')
        .replaceAll('http://10.161.170.81:3000', 'http://10.161.175.199:3000');
  }

  // API methods with loading states
  Future<List<Product>> getAllProduct({bool showSnack = false}) async {
    try {
      _isProductsLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'products');
      ApiResponse<List<Product>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var productJson = Map<String, dynamic>.from(item);
          if (productJson['images'] != null) {
            var images = (productJson['images'] as List).map((image) {
              var imageMap = Map<String, dynamic>.from(image);
              if (imageMap['url'] != null) {
                imageMap['url'] = _fixImageUrl(imageMap['url']);
              }
              return imageMap;
            }).toList();
            productJson['images'] = images;
          }
          return Product.fromJson(productJson);
        }).toList(),
      );
      _allProducts = apiResponse.data ?? [];
      _filteredProducts = List.from(_allProducts);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showSuccessSnackBar(e.toString());
      rethrow;
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
    return _filteredProducts;
  }

  // NEW: getAllOrders - fetch all orders and keep them in provider
  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'orders');
      ApiResponse<List<Order>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          return Order.fromJson(item);
        }).toList(),
      );

      _allOrders = apiResponse.data ?? [];
      _filteredOrders = List.from(_allOrders);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    notifyListeners();
    return _filteredOrders;
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      _isCategoriesLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'categories');
      ApiResponse<List<Category>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var categoryJson = Map<String, dynamic>.from(item);
          if (categoryJson['image'] != null) {
            categoryJson['image'] = _fixImageUrl(categoryJson['image']);
          }
          return Category.fromJson(categoryJson);
        }).toList(),
      );
      _allCategories = apiResponse.data ?? [];
      _filteredCategories = List.from(_allCategories);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showSuccessSnackBar(e.toString());
      rethrow;
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
    return _filteredCategories;
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      _isPostersLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'posters');
      ApiResponse<List<Poster>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var posterJson = Map<String, dynamic>.from(item);
          if (posterJson['imageUrl'] != null) {
            posterJson['imageUrl'] = _fixImageUrl(posterJson['imageUrl']);
          }
          return Poster.fromJson(posterJson);
        }).toList(),
      );
      _allPosters = apiResponse.data ?? [];
      _filteredPosters = List.from(_allPosters);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showSuccessSnackBar(e.toString());
      rethrow;
    } finally {
      _isPostersLoading = false;
      notifyListeners();
    }
    return _filteredPosters;
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'subCategories');
      ApiResponse<List<SubCategory>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) =>
            (json as List).map((item) => SubCategory.fromJson(item)).toList(),
      );
      _allSubCategories = apiResponse.data ?? [];
      _filteredSubCategories = List.from(_allSubCategories);
      notifyListeners();
      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredSubCategories;
  }

  void filteredSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((SubCategory) {
        return (SubCategory.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'brands');
      ApiResponse<List<Brand>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
      );
      _allBrands = apiResponse.data ?? [];
      _filteredBrands = List.from(_allBrands);
      notifyListeners();
      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredBrands;
  }

  void filteredBrands(String keyword) {
    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((Brand) {
        return (Brand.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowcase = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final ProductNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowcase);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final subCategoryNameContainsKeyword =
            product.proSubCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final brandNameContainsKeyword =
            product.proBrandId?.name?.toLowerCase().contains(lowcase) ?? false;

        return ProductNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword ||
            brandNameContainsKeyword;
      }).toList();
    }
    notifyListeners();
  }

  double calculateDiscountPercentage(num originalPrice, num? discountedPrice) {
    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than zero.');
    }

    num finalDiscountedPrice = discountedPrice ?? originalPrice;

    if (finalDiscountedPrice > originalPrice) {
      return originalPrice.toDouble();
    }

    double discount =
        ((originalPrice - finalDiscountedPrice) / originalPrice) * 100;

    return discount;
  } // In DataProvider, add methods to clear and reload user-specific data

  void clearUserSpecificData() {
    _allOrders = [];
    _filteredOrders = [];

    // Notify listeners that data has been cleared
    notifyListeners();
  }

  Future<void> reloadUserSpecificData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Only reload orders (which are user-specific)
      await getAllOrders();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        getAllCategory(),
        getAllSubCategory(),
        getAllBrands(),
        getAllProduct(),
        getAllPosters(),
        getAllOrders(), // Add this line
      ]);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
