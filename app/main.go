package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Get connection details from environment variables
	uri := os.Getenv("DOCDB_CONNECTION_STRING")
	if uri == "" {
		log.Fatal("DOCDB_CONNECTION_STRING environment variable not set")
	}

	database := "mydb"
	collection := "mycollection"

	// TLS config (AWS DocumentDB requires SSL)
	tlsConfig := &tls.Config{
		InsecureSkipVerify: true,
	}

	clientOpts := options.Client().ApplyURI(uri).SetTLSConfig(tlsConfig)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	fmt.Println("Connecting to DocumentDB...")
	client, err := mongo.Connect(ctx, clientOpts)
	if err != nil {
		log.Fatal("Connection error:", err)
	}
	defer client.Disconnect(ctx)

	// Ping the database to verify connection
	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal("Failed to ping database:", err)
	}
	fmt.Println("Successfully connected to DocumentDB!")

	coll := client.Database(database).Collection(collection)

	// 1. Create Index
	fmt.Println("Creating index...")
	indexModel := mongo.IndexModel{
		Keys:    bson.D{{Key: "email", Value: 1}},
		Options: options.Index().SetUnique(true),
	}
	_, err = coll.Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		log.Fatal("Index creation failed:", err)
	}
	fmt.Println("Index created on 'email' field.")

	// 2. Insert Document
	fmt.Println("Inserting document...")
	doc := bson.D{{Key: "email", Value: "user@example.com"}, {Key: "name", Value: "Alice"}}
	insertRes, err := coll.InsertOne(ctx, doc)
	if err != nil {
		log.Fatal("Insert failed:", err)
	}
	fmt.Println("Inserted ID:", insertRes.InsertedID)

	// 3. Update Document
	fmt.Println("Updating document...")
	filter := bson.D{{Key: "email", Value: "user@example.com"}}
	update := bson.D{{Key: "$set", Value: bson.D{{Key: "name", Value: "Alice Smith"}}}}
	updateRes, err := coll.UpdateOne(ctx, filter, update)
	if err != nil {
		log.Fatal("Update failed:", err)
	}
	fmt.Println("Updated count:", updateRes.ModifiedCount)

	// 4. Delete Document
	fmt.Println("Deleting document...")
	deleteRes, err := coll.DeleteOne(ctx, filter)
	if err != nil {
		log.Fatal("Delete failed:", err)
	}
	fmt.Println("Deleted count:", deleteRes.DeletedCount)

	fmt.Println("All operations completed successfully!")
}
