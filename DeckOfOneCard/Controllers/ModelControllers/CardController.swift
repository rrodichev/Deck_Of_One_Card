//
//  CardController.swift
//  DeckOfOneCard
//
//  Created by Rozalia Rodichev on 8/3/21.
//  Copyright © 2021 Warren. All rights reserved.
//

import Foundation
import UIKit

class CardController {
    
    // https://deckofcardsapi.com/api/deck/new/draw/?count=1
    static let baseURL = URL(string: "https://deckofcardsapi.com/api/deck/new/draw/?count=1")
    
    // MARK: - Fetch functions
    static func fetchCard(completion: @escaping (Result<Card, CardError>) -> Void) {
        // step 1 - Prepare URL
        guard let baseURL = baseURL else {
            return completion(.failure(.invalidURL))
        }
        
        print(baseURL)
        
        // step 2 - Contact Server
        URLSession.shared.dataTask(with: baseURL) { data, response, error in
            
            // step 3 - Handle errors from the server
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            
            if let response = response as? HTTPURLResponse {
                print("STATUS CODE: \(response.statusCode)")
            }
            
            // step 4 - Check for JSON Data
            guard let data = data else {
                return completion(.failure(.noData))
            }
            
            // step 5 - Decode JSON into a Card
            do {
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                
                guard let card = topLevelObject.cards.first else {
                    return completion(.failure(.noData))
                }
                return completion(.success(card))

            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
        
    }
    
    static func fetchImage(for card: Card, completion: @escaping (Result<UIImage, CardError>) -> Void) {
        
        // 1 - Prepare URL
        guard let url = card.image else {
            return completion(.failure(.invalidURL))
        }
        
        // 2 - Contact server
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // 3 - Handle errors from the server
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            
            if let response = response as? HTTPURLResponse {
                print("STATUS CODE: \(response.statusCode)")
            }
            
            // 4 - Check for image data
            guard let data = data else {
                return completion(.failure(.noData))
            }
            
            // 5 - Initialize an image from the data
            guard let image = UIImage(data: data) else {
                return completion(.failure(.unableToDecode))
            }
            
            return completion(.success(image))
        }.resume()
    }
    
}//End of class
