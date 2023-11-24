//
//  AuthenticationViewModel.swift
//  AuthentificationWithGoogle
//
//  Created by Thibault GODEFROY on 24/11/2023.
//

import Firebase
import GoogleSignIn
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    
    // 1
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    // 2
    @Published var state: SignInState = .signedOut
    
    // MARK: - SignIn
    func signIn() {
        // 1 : Vérifier s'il y a une connexion précédente
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            // Si oui; restaurer la connexion précédente
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                // Authentifier l'utilisateur avec les informations obtenues ou gérer l'erreur
                authenticateUser(for: user, with: error)
            }
        } else {
            // 2 : S'il n'y a pas de connexion précédente, obtenir l'ID client depuis Firebase
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // 3 : Créer une configuration de Connnexion Google en utilisnt l'ID client obtenu
            let configuration = GIDConfiguration(clientID: clientID)
            
            // 4 : Obtenir le contrôleur de vue racine de la fenêtre principale
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            // 5 : Effectuer une Connexion Google avec la configuration fournie et le contexte de présentation
            //        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                authenticateUser(for: result?.user, with: error)
            }
        }
    }
    
    // MARK: - AuthenticateUser
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1 : Vérifier s'il y aune erreur d'authentification
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // 2 : Si aucune erreur, obtenir les inforamations d'authentification de l'utilisateur
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        
        // 3
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.state = .signedIn
            }
        }
    }
    
    // MARK: - SignOut
    
    func signOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
        
        do {
            // 2
            try Auth.auth().signOut()
            
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
}
