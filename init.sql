--Enum types
CREATE TYPE user_role AS ENUM ('admin', 'client');
CREATE TYPE account_type as ENUM ('universal', 'for_payments');
CREATE TYPE deposit_type as ENUM ('universal', 'modern', 'stable');
CREATE TYPE loan_type as ENUM('convenient', 'profitable');
CREATE TYPE transfer_status as ENUM ('pending', 'completed');
CREATE TYPE currency as ENUM('uah', 'usd', 'eur');
CREATE TYPE mobile_platform as ENUM('android', 'ios');
CREATE TYPE session_type as ENUM('mobile_android', 'mobile_ios', 'web');
CREATE TYPE payment_card_type as ENUM('visa', 'mastercard');


--Tables
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "email" TEXT UNIQUE NOT NULL,
  "first_name" TEXT NOT NULL,
  "last_name" TEXT NOT NULL,
  "middle_name" TEXT,
  "date_of_birth" date NOT NULL,
  "role" user_role NOT NULL,
  "residential_address_id" INT NOT NULL,
  "registration_address_id" INT NOT NULL,
  "facility_id" INT,
  "language_id" INT NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW()),
  "updated_at" TIMESTAMP,
  "updated_by" INT
);

CREATE TABLE "languages" (
  "id" SERIAL PRIMARY KEY,
  "name" TEXT UNIQUE NOT NULL
);

CREATE TABLE "addresses" (
  "id" SERIAL PRIMARY KEY,
  "country_id" INT NOT NULL,
  "city" TEXT NOT NULL,
  "street" TEXT NOT NULL,
  "unit" TEXT NOT NULL
);

CREATE TABLE "countries" (
  "id" SERIAL PRIMARY KEY,
  "name" TEXT UNIQUE NOT NULL
);

CREATE TABLE "accounts" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "type" account_type NOT NULL,
  "currency" currency NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW())
);

CREATE TABLE "transfers" (
  "id" SERIAL PRIMARY KEY,
  "status" transfer_status NOT NULL,
  "from_account_id" INT NOT NULL,
  "to_account_id" INT NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW()),
  "exchange_rate" REAL,
  "amount" REAL NOT NULL,
  "comment" TEXT,
  "deposit_id" INT,
  "load_id" INT
);

CREATE TABLE "deposits" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "type" deposit_type NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW()),
  "ends_at" TIMESTAMP NOT NULL,
  "terminated_at" TIMESTAMP,
  "terminated_by" INT,
  "termination_reason" TEXT,
  "INTerest" REAL NOT NULL
);

CREATE TABLE "loans" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "type" loan_type NOT NULL,
  "rate" REAL NOT NULL,
  "amount" REAL NOT NULL,
  "repaid_amount" REAL NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW()),
  "account_id" INT
);

CREATE TABLE "sessions" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT,
  "type" session_type NOT NULL,
  "terminated_at" TIMESTAMP
);

CREATE TABLE "payment_cards" (
  "id" SERIAL PRIMARY KEY,
  "account_id" INT NOT NULL,
  "type" payment_card_type NOT NULL,
  "number" TEXT NOT NULL,
  "cvc" TEXT NOT NULL,
  "expiration_month" INT NOT NULL,
  "expiration_year" INT NOT NULL
);

CREATE TABLE "exchange_rates" (
  "id" SERIAL PRIMARY KEY,
  "from_currency" currency NOT NULL,
  "to_currency" currency NOT NULL,
  "rate" REAL NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW())
);

CREATE TABLE "facilities" (
  "id" SERIAL PRIMARY KEY,
  "address_id" INT NOT NULL,
  "number" INT NOT NULL
);

CREATE TABLE "atms" (
  "id" SERIAL PRIMARY KEY,
  "address_id" INT NOT NULL,
  "deactivated_at" TIMESTAMP
);

CREATE TABLE "mobile_application_builds" (
  "id" SERIAL PRIMARY KEY,
  "version" TEXT NOT NULL,
  "platform" mobile_platform NOT NULL,
  "created_at" TIMESTAMP NOT NULL DEFAULT (NOW())
);

CREATE TABLE "mobile_application_ratings" (
  "build_id" INT NOT NULL,
  "rating" INT NOT NULL,
  "user_id" INT
);

CREATE TABLE "administrator_ratings" (
  "administrator_user_id" INT NOT NULL,
  "rating" INT NOT NULL,
  "user_id" INT
);

--Foreign keys
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


--Triggers and functions
CREATE FUNCTION find_latest_exchange_rate(from_currency_arg currency, to_currency_arg currency) RETURNS REAL
LANGUAGE SQL
AS $$
SELECT rate FROM exchange_rates as er WHERE er.from_currency = from_currency_arg AND er.to_currency = to_currency_arg ORDER BY created_at DESC LIMIT 1
$$;

--
CREATE PROCEDURE terminate_user_sessions_except_one(user_id_arg INT, session_to_leave_id_arg INT)
LANGUAGE SQL
AS $$
UPDATE sessions as s SET terminated_at = NOW() WHERE terminated_at is NULL AND s.user_id = user_id_arg AND id != session_to_leave_id_arg;
$$;

--
CREATE FUNCTION set_updated_at_trigger() RETURNS trigger
LANGUAGE plpgsql AS
$$
BEGIN
   NEW.updated_at := current_timestamp;
   RETURN NEW;
END;
$$;

CREATE TRIGGER users_before_update_trigger BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE set_updated_at_trigger();

-- 
CREATE FUNCTION calculate_mobile_app_version_rating(platform_arg mobile_platform, version_arg TEXT) RETURNS REAL
LANGUAGE SQL
AS $$
SELECT AVG(mar.rating) FROM mobile_application_ratings as mar INNER JOIN mobile_application_builds as mab
ON mar.build_id = mab.id AND mab.platform = platform_arg AND mab.version = version_arg
$$;

--
CREATE FUNCTION calculate_mobile_app_rating() RETURNS REAL
LANGUAGE SQL
AS $$
SELECT AVG(mar.rating) FROM mobile_application_ratings as mar;
$$;

--
CREATE FUNCTION calculate_administrator_rating(administrator_user_id_arg INT) RETURNS REAL
LANGUAGE SQL
AS $$
SELECT AVG(rating) FROM administrator_ratings WHERE user_id = administrator_user_id_arg;
$$;

--
CREATE FUNCTION find_facilities_in_city(city_arg TEXT) RETURNS TABLE(facility_number TEXT, street TEXT, unit TEXT)
LANGUAGE SQL
AS $$
SELECT f.number, a.street, a.unit FROM facilities as f INNER JOIN addresses as a ON f.address_id = a.id AND a.city = city_arg;
$$;

--
CREATE FUNCTION find_atms_in_city(city_arg TEXT) RETURNS TABLE(atm_id TEXT, street TEXT, unit TEXT)
LANGUAGE SQL
AS $$
SELECT atms.id, a.street, a.unit FROM atms INNER JOIN addresses as a ON atms.address_id = a.id AND a.city = city_arg;
$$;

--
CREATE FUNCTION calculate_account_balance(account_id_arg INT) RETURNS REAL
LANGUAGE SQL
AS $$
SELECT positive_sum - negative_sum FROM (
SELECT (
  (
    SELECT SUM(final_amount) FROM (
        SELECT (
            CASE
                WHEN exchange_rate IS NOT NULL THEN amount * exchange_rate
                ELSE amount
            END
        ) as final_amount FROM transfers WHERE to_account_id = account_id_arg AND status = 'completed'
    ) as final_amounts)
  ) as positive_sum,
  (
    SELECT SUM(amount) FROM transfers WHERE from_account_id = account_id_arg AND status = 'completed'
  ) as negative_sum
) as sums;
$$;

--
CREATE PROCEDURE complete_pending_transfers()
LANGUAGE SQL
AS $$
UPDATE transfers SET status = 'completed' WHERE status = 'pending';
$$;

--Some values
INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('usd', 'uah', 36.65);
INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('usd', 'uah', 36.61);
INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('usd', 'uah', 36.56);

INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('uah', 'usd', 0.027);
INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('uah', 'usd', 0.028);
INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES('uah', 'usd', 0.028);

INSERT INTO mobile_application_builds (version, platform) VALUES('1.0.0', 'ios');
INSERT INTO mobile_application_builds (version, platform) VALUES('1.0.0', 'android');

INSERT INTO mobile_application_builds (version, platform) VALUES('1.0.1', 'ios');
INSERT INTO mobile_application_builds (version, platform) VALUES('1.0.1', 'android');

INSERT INTO mobile_application_ratings (build_id, rating) VALUES(1, 2);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(1, 3);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(1, 2);

INSERT INTO mobile_application_ratings (build_id, rating) VALUES(2, 5);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(2, 4);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(2, 5);

INSERT INTO mobile_application_ratings (build_id, rating) VALUES(3, 3);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(3, 4);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(3, 5);

INSERT INTO mobile_application_ratings (build_id, rating) VALUES(4, 3);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(4, 3);
INSERT INTO mobile_application_ratings (build_id, rating) VALUES(4, 5);
