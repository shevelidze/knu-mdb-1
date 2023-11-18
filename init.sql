CREATE TYPE user_role AS ENUM ('admin', 'client');
CREATE TYPE account_type as ENUM ('universal', 'for_payments');
CREATE TYPE deposit_type as ENUM ('universal', 'modern', 'stable');
CREATE TYPE loan_type as ENUM('convenient', 'profitable');
CREATE TYPE transfer_status as ENUM ('pending', 'completed');
CREATE TYPE currency as ENUM('uah', 'usd', 'eur');
CREATE TYPE mobile_platform as ENUM('android', 'ios');
CREATE TYPE session_type as ENUM('mobile_android', 'mobile_ios', 'web');
CREATE TYPE payment_card_type as ENUM('visa', 'mastercard');

CREATE TABLE "users" (
  "id" serial PRIMARY KEY,
  "email" text UNIQUE NOT NULL,
  "first_name" text NOT NULL,
  "last_name" text NOT NULL,
  "middle_name" text,
  "date_of_birth" date NOT NULL,
  "role" user_role NOT NULL,
  "residential_address_id" int NOT NULL,
  "registration_address_id" int NOT NULL,
  "facility_id" int,
  "language_id" int NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW()),
  "updated_at" timestamp,
  "updated_by" int
);

CREATE TABLE "languages" (
  "id" serial PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "addresses" (
  "id" serial PRIMARY KEY,
  "country_id" int NOT NULL,
  "city" text NOT NULL,
  "street" text NOT NULL,
  "unit" text NOT NULL
);

CREATE TABLE "countries" (
  "id" serial PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "accounts" (
  "id" serial PRIMARY KEY,
  "user_id" int NOT NULL,
  "type" account_type NOT NULL,
  "currency" currency NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW())
);

CREATE TABLE "transfers" (
  "id" serial PRIMARY KEY,
  "status" transfer_status NOT NULL,
  "from_account_id" int NOT NULL,
  "to_account_id" int NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW()),
  "exchange_rate" real,
  "amount" real NOT NULL,
  "comment" text,
  "deposit_id" int,
  "load_id" int
);

CREATE TABLE "deposits" (
  "id" serial PRIMARY KEY,
  "user_id" int NOT NULL,
  "type" deposit_type NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW()),
  "ends_at" timestamp NOT NULL,
  "terminated_at" timestamp,
  "terminated_by" int,
  "termination_reason" text,
  "interest" real NOT NULL
);

CREATE TABLE "loans" (
  "id" serial PRIMARY KEY,
  "user_id" int NOT NULL,
  "type" loan_type NOT NULL,
  "rate" real NOT NULL,
  "amount" real NOT NULL,
  "repaid_amount" real NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW()),
  "account_id" int
);

CREATE TABLE "sessions" (
  "id" serial PRIMARY KEY,
  "user_id" int,
  "type" session_type NOT NULL,
  "terminated_at" timestamp
);

CREATE TABLE "payment_cards" (
  "id" serial PRIMARY KEY,
  "account_id" int NOT NULL,
  "type" payment_card_type NOT NULL,
  "number" text NOT NULL,
  "cvc" text NOT NULL,
  "expiration_month" int NOT NULL,
  "expiration_year" int NOT NULL
);

CREATE TABLE "exchange_rates" (
  "id" serial PRIMARY KEY,
  "from_currency" currency NOT NULL,
  "to_currency" currency NOT NULL,
  "rate" real NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW())
);

CREATE TABLE "facilities" (
  "id" serial PRIMARY KEY,
  "address_id" int NOT NULL,
  "number" int NOT NULL
);

CREATE TABLE "atms" (
  "id" serial PRIMARY KEY,
  "address_id" int NOT NULL,
  "deactivated_at" timestamp
);

CREATE TABLE "mobile_application_builds" (
  "id" serial PRIMARY KEY,
  "version" text NOT NULL,
  "platform" mobile_platform NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (NOW())
);

CREATE TABLE "mobile_application_ratings" (
  "build_id" int NOT NULL,
  "rating" int NOT NULL,
  "user_id" int
);

CREATE TABLE "administrator_ratings" (
  "administrator_user_id" int NOT NULL,
  "rating" int NOT NULL,
  "user_id" int
);

ALTER TABLE "users" ADD FOREIGN KEY ("residential_address_id") REFERENCES "addresses" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("registration_address_id") REFERENCES "addresses" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("facility_id") REFERENCES "facilities" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("language_id") REFERENCES "languages" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "addresses" ADD FOREIGN KEY ("country_id") REFERENCES "countries" ("id");

ALTER TABLE "accounts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("from_account_id") REFERENCES "accounts" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("to_account_id") REFERENCES "accounts" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("deposit_id") REFERENCES "deposits" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("load_id") REFERENCES "loans" ("id");

ALTER TABLE "deposits" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "deposits" ADD FOREIGN KEY ("terminated_by") REFERENCES "users" ("id");

ALTER TABLE "loans" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "loans" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "payment_cards" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "facilities" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

ALTER TABLE "atms" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

ALTER TABLE "mobile_application_ratings" ADD FOREIGN KEY ("build_id") REFERENCES "mobile_application_builds" ("id");

ALTER TABLE "mobile_application_ratings" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "administrator_ratings" ADD FOREIGN KEY ("administrator_user_id") REFERENCES "users" ("id");

ALTER TABLE "administrator_ratings" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
