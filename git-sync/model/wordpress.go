package model

import "os"

// WordpressConfig encapsulates all the configurations for a Wordpress site.
type WordpressConfig struct {
	WPGeneric        bool
	DeployName       string
	DeployProtocol   string
	DeployURL        string
	DatabaseName     string
	DatabaseUsername string
	DatabasePassword string
	DatabaseHost     string
	AuthKey          string
	SecureAuthKey    string
	LoggedInKey      string
	NonceKey         string
	AuthSalt         string
	SecureAuthSalt   string
	LoggedInSalt     string
	NonceSalt        string
	Docroot          string
	TablePrefix      string
}

// NewWordpressConfig produces a WordpressConfig object with defaults.
func NewWordpressConfig() *WordpressConfig {
	return &WordpressConfig{
		WPGeneric:        false,
		DatabaseName:     "data",
		DatabaseUsername: "root",
		DatabasePassword: "root",
		DatabaseHost:     "127.0.0.1",
		Docroot:          "/var/www/html/docroot",
		TablePrefix:      "wp_",
		DeployURL:        os.Getenv("DEPLOY_URL"),
		DeployProtocol:   os.Getenv("DEPLOY_PROTOCOL"),
	}
}
