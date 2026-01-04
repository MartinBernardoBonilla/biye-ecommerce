// lib/core/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario actual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro con email y contraseña
  Future<UserAuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Crear documento del usuario en Firestore
        await _createUserDocument(
          user: user,
          firstName: firstName,
          lastName: lastName,
        );

        return UserAuthResult(
          success: true,
          user: user,
          message: 'Usuario registrado exitosamente',
        );
      }

      return UserAuthResult(
        success: false,
        message: 'Error al crear el usuario',
      );
    } on FirebaseAuthException catch (e) {
      return UserAuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (e) {
      return UserAuthResult(success: false, message: 'Error inesperado: $e');
    }
  }

  // Login con email y contraseña
  Future<UserAuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return UserAuthResult(
        success: true,
        user: credential.user,
        message: 'Inicio de sesión exitoso',
      );
    } on FirebaseAuthException catch (e) {
      return UserAuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (e) {
      return UserAuthResult(success: false, message: 'Error inesperado: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Enviar email de verificación
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Crear documento del usuario en Firestore
  Future<void> _createUserDocument({
    required User user,
    required String firstName,
    required String lastName,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': '$firstName $lastName',
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
      'isActive': true,
    };

    await userDoc.set(userData, SetOptions(merge: true));
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Actualizar datos del usuario
  Future<bool> updateUserData({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...?data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Mensajes de error en español
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Error de conexión';
      default:
        return 'Error desconocido: $errorCode';
    }
  }
}

// Modelo para resultado de autenticación
class UserAuthResult {
  final bool success;
  final User? user;
  final String message;

  UserAuthResult({required this.success, this.user, required this.message});
}

// Modelo de usuario extendido
class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastSignIn;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastSignIn,
    this.isActive = true,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: data['createdAt']?.toDate(),
      lastSignIn: data['lastSignIn']?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastSignIn': lastSignIn,
      'isActive': isActive,
    };
  }
}
