import 'dart:async';

import 'package:DFD/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  String? _verificationId;
  bool _isVerifyEnabled = false;

  OTPScreen({required this.phoneNumber,required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}
FirebaseAuth _auth = FirebaseAuth.instance;
class _OTPScreenState extends State<OTPScreen> {
  int _resendTimer = 30;
  bool _isResendEnabled = false;
  List<TextEditingController> _otpControllers = [];
  late ProgressDialog _progressDialog;




  @override
  void initState() {
    super.initState();
    _initializeOTPControllers();
    _startResendTimer();
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(
      message: "Please wait...",

      progressWidget: Container(

          padding: EdgeInsets.all(18.0), child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
      )),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
  }

  @override
  void dispose() {
    _disposeOTPControllers();
    super.dispose();
  }

  void _initializeOTPControllers() {
    for (int i = 0; i < 6; i++) {
      _otpControllers.add(TextEditingController());
    }
  }

  void _disposeOTPControllers() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 30;
    });

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_resendTimer == 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the OTP boxes
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7ECD6), Color(0xFFD3B78F)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, 40),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Delivering Fresh to Your Doorstep',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8D6E4C),
                          fontFamily: 'DancingFont',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'We have sent a verification code to',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E4C),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E4C),
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 6; i++)
                            buildOTPBox(i),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isResendEnabled ? _handleResendSMS : null,
                            child: Text(
                              _isResendEnabled ? 'Resend OTP' : 'Resend OTP in $_resendTimer sec',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isResendEnabled ? Color(0xFF8D6E4C) : Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              String enteredOTP = '';
                              for (var controller in _otpControllers) {
                                enteredOTP += controller.text;
                              }
                              _verifyOTP(enteredOTP);
                              _progressDialog.hide();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF8D6E4C),
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Confirm OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOTPBox(int index) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: _otpControllers[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
          cursorColor: Color(0xFF8D6E4C),
          maxLength: 1,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
            counterText: '', // Hide the character counter
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown),
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
          onChanged: (value) {
            // Move focus to the next OTP box after typing one number
            if (value.isNotEmpty) {
              if (index < _otpControllers.length - 1) {
                _otpControllers[index + 1].text = '';
                FocusScope.of(context).nextFocus();
              }
            } else {
              // Move focus to the previous OTP box when using backspace
              if (index > 0) {
                FocusScope.of(context).previousFocus();
              }
            }
          },
        ),
      ),
    );
  }

  void _handleResendSMS() {
    // TODO: Perform backend task for resending SMS
    _progressDialog.show();
    String phoneNumber = widget.phoneNumber;
    _sendOTP(phoneNumber);
    // Disable the resend button for 30 seconds and start the timer
    setState(() {
      _isResendEnabled = false;
    });

    _startResendTimer();
  }

  void _sendOTP(String phoneNumber) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verificationId) {
      // Auto-retrieval of verification code timed out
      // You can implement a fallback mechanism or display an error message here
    };

    final PhoneCodeSent smsCodeSent = (String verificationId, [int? forceResendingToken]) {
      // Handle the verification code being sent to the user
      // You can save the verificationId to use it later for manual code entry

      // Update the verificationId and enable the "Verify OTP" button
      setState(() {
        widget._verificationId = verificationId;
        widget._isVerifyEnabled = true;
      });

      // Show a toast or display a message to inform the user that the OTP has been sent
      Fluttertoast.showToast(
        msg: 'OTP has been sent to ${widget.phoneNumber}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    };

    final PhoneVerificationCompleted verifiedSuccess = (PhoneAuthCredential authCredential) {
      // Handle the phone verification process on success
      // You can navigate to the main screen or perform any other actions here

      // Example: Navigate to the main screen
      _progressDialog.hide();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    };

    final PhoneVerificationFailed verifiedFailed = (FirebaseAuthException exception) {
      // Handle the phone verification process on failure
      // You can display an error message or implement a retry mechanism here

      // Show a toast or display an error message
      _progressDialog.hide();
      Fluttertoast.showToast(
        msg: exception.message ?? 'Verification failed. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifiedFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  // Function to verify the OTP entered by the user
  void _verifyOTP(String otp) async {
    _progressDialog.show();
    // Create a PhoneAuthCredential using the verification ID and OTP
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId, // Replace with the verification ID passed from login_screen.dart
      smsCode: otp,
    );

    try {
      // Sign in the user with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // User successfully verified, navigate to the main.dart page
      _progressDialog.hide();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(), // Replace MainPage with your desired page
        ),
      );
    } catch (e) {
      // Handle verification failure
      _progressDialog.hide();
      Fluttertoast.showToast(
        msg: 'Invalid OTP, please try again',
        // ...
      );
    }
  }
}
