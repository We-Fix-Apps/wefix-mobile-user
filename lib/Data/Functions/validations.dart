class Validations {
  // * Email Validation
  static bool validateEmail(String email) {
    if (email == '' || email.isEmpty) {
      return false;
    }
    const regexPattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(regexPattern);
    return regex.hasMatch(email);
  }

  // * Password Validation
  static bool isPasswordValid(String password) {
    // const pattern =
    //     r'^(?=.*?[!@#\$%^&*()_+{}\[\]:;<>,.?~\\|/`-])[\w!@#\$%^&*()_+{}\[\]:;<>,.?~\\|/`-]{8,}$';
    // final regex = RegExp(pattern);
    // return regex.hasMatch(password);
    if (password.length >= 8) {
      return true;
    } else {
      return false;
    }
  }

  // * Not Null Validation
  static dynamic checkNull(String value, String message) {
    if (value != '') {
      return null;
    } else {
      return message;
    }
  }
}
