-- =====================================================================
-- Airline Seat Management — schema
-- Portable SQL (tested on DuckDB; runs on PostgreSQL with no changes)
-- =====================================================================

CREATE TABLE airports (
    airport_code   CHAR(3)      PRIMARY KEY,
    city           VARCHAR(60)  NOT NULL,
    country        VARCHAR(60)  NOT NULL
);

CREATE TABLE aircraft_types (
    aircraft_type_id  INTEGER      PRIMARY KEY,
    model             VARCHAR(40)  NOT NULL,
    total_seats       INTEGER      NOT NULL
);

-- One row per physical seat on each aircraft layout
CREATE TABLE seat_map (
    aircraft_type_id  INTEGER      NOT NULL REFERENCES aircraft_types(aircraft_type_id),
    seat_no           VARCHAR(4)   NOT NULL,          -- e.g. '12A'
    row_no            INTEGER      NOT NULL,
    seat_letter       CHAR(1)      NOT NULL,
    letter_pos        INTEGER      NOT NULL,          -- position across the row (1 = leftmost)
    cabin             VARCHAR(10)  NOT NULL CHECK (cabin IN ('Business','Premium','Economy')),
    seat_type         VARCHAR(6)   NOT NULL CHECK (seat_type IN ('Window','Middle','Aisle')),
    is_exit_row       BOOLEAN      NOT NULL DEFAULT FALSE,
    PRIMARY KEY (aircraft_type_id, seat_no)
);

CREATE TABLE flights (
    flight_id         INTEGER      PRIMARY KEY,
    flight_no         VARCHAR(8)   NOT NULL,
    origin            CHAR(3)      NOT NULL REFERENCES airports(airport_code),
    destination       CHAR(3)      NOT NULL REFERENCES airports(airport_code),
    departure_ts      TIMESTAMP    NOT NULL,
    aircraft_type_id  INTEGER      NOT NULL REFERENCES aircraft_types(aircraft_type_id),
    status            VARCHAR(10)  NOT NULL CHECK (status IN ('Scheduled','Departed'))
);

CREATE TABLE passengers (
    passenger_id    INTEGER      PRIMARY KEY,
    first_name      VARCHAR(40)  NOT NULL,
    last_name       VARCHAR(40)  NOT NULL,
    birth_date      DATE         NOT NULL,
    loyalty_tier    VARCHAR(10)  NOT NULL CHECK (loyalty_tier IN ('None','Silver','Gold','Platinum')),
    loyalty_points  INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE bookings (
    booking_id   INTEGER      PRIMARY KEY,
    booking_ref  CHAR(6)      NOT NULL UNIQUE,
    booked_at    TIMESTAMP    NOT NULL,
    channel      VARCHAR(10)  NOT NULL CHECK (channel IN ('Web','App','Agency'))
);

-- A ticket = one passenger on one flight
CREATE TABLE tickets (
    ticket_id        INTEGER       PRIMARY KEY,
    booking_id       INTEGER       NOT NULL REFERENCES bookings(booking_id),
    passenger_id     INTEGER       NOT NULL REFERENCES passengers(passenger_id),
    flight_id        INTEGER       NOT NULL REFERENCES flights(flight_id),
    cabin_booked     VARCHAR(10)   NOT NULL,
    fare_eur         DECIMAL(8,2)  NOT NULL,
    seat_preference  VARCHAR(6),                    -- 'Window' / 'Aisle' / NULL
    status           VARCHAR(10)   NOT NULL CHECK (status IN ('Confirmed','Cancelled','NoShow','Boarded'))
);

CREATE TABLE seat_assignments (
    ticket_id        INTEGER      PRIMARY KEY REFERENCES tickets(ticket_id),
    flight_id        INTEGER      NOT NULL REFERENCES flights(flight_id),
    seat_no          VARCHAR(4)   NOT NULL,
    assigned_at      TIMESTAMP    NOT NULL,
    assignment_type  VARCHAR(10)  NOT NULL CHECK (assignment_type IN ('Selected','Auto','Upgrade')),
    UNIQUE (flight_id, seat_no)                     -- a seat can only be sold once per flight
);

CREATE TABLE upgrade_requests (
    request_id       INTEGER      PRIMARY KEY,
    ticket_id        INTEGER      NOT NULL REFERENCES tickets(ticket_id),
    requested_cabin  VARCHAR(10)  NOT NULL,
    requested_at     TIMESTAMP    NOT NULL
);

-- ---------------------------------------------------------------------
-- Booking website: checkout funnel, payments and refunds
-- ---------------------------------------------------------------------

-- One visit to the booking flow. booking_id is filled only when the customer paid.
CREATE TABLE checkout_sessions (
    session_id       INTEGER      PRIMARY KEY,
    started_at       TIMESTAMP    NOT NULL,
    channel          VARCHAR(10)  NOT NULL CHECK (channel IN ('Web','App','Agency')),
    flight_id        INTEGER      NOT NULL REFERENCES flights(flight_id),
    passenger_count  INTEGER      NOT NULL,
    furthest_step    VARCHAR(20)  NOT NULL CHECK (furthest_step IN
                         ('Search','Seats','Passenger details','Payment','Paid')),
    booking_id       INTEGER      REFERENCES bookings(booking_id)
);

-- Every payment attempt, successful or not. Amount = fares + €12 per self-selected seat (not in Business).
-- booking_id is empty when the customer gave up after a failed payment (no booking was created).
CREATE TABLE payments (
    payment_id      INTEGER       PRIMARY KEY,
    session_id      INTEGER       NOT NULL REFERENCES checkout_sessions(session_id),
    booking_id      INTEGER       REFERENCES bookings(booking_id),
    attempt_no      INTEGER       NOT NULL,
    attempted_at    TIMESTAMP     NOT NULL,
    method          VARCHAR(15)   NOT NULL,       -- Card, PayPal, Bizum, Apple Pay, Google Pay, Bank transfer
    amount_eur      DECIMAL(9,2)  NOT NULL,
    status          VARCHAR(10)   NOT NULL CHECK (status IN ('Succeeded','Failed')),
    failure_reason  VARCHAR(30)
);

-- Money returned for a cancelled ticket (Economy keeps a €30 cancellation fee)
CREATE TABLE refunds (
    refund_id    INTEGER       PRIMARY KEY,
    payment_id   INTEGER       NOT NULL REFERENCES payments(payment_id),
    ticket_id    INTEGER       NOT NULL REFERENCES tickets(ticket_id),
    refunded_at  TIMESTAMP     NOT NULL,
    amount_eur   DECIMAL(9,2)  NOT NULL,
    reason       VARCHAR(40)   NOT NULL
);

-- Promo codes and the rules they must follow (NULL = no restriction)
CREATE TABLE promo_codes (
    promo_code        VARCHAR(12)   PRIMARY KEY,
    campaign          VARCHAR(40)   NOT NULL,
    discount_type     VARCHAR(7)    NOT NULL CHECK (discount_type IN ('Percent','Fixed')),
    discount_value    DECIMAL(6,2)  NOT NULL,      -- % or € depending on type
    min_spend_eur     DECIMAL(8,2),
    valid_from        TIMESTAMP     NOT NULL,
    valid_to          TIMESTAMP     NOT NULL,
    max_uses          INTEGER,
    channel_only      VARCHAR(10),
    destination_only  CHAR(3)
);

-- A promo code applied to a booking. gross = fares + seat fees before the discount.
CREATE TABLE booking_promotions (
    booking_id    INTEGER       PRIMARY KEY REFERENCES bookings(booking_id),
    promo_code    VARCHAR(12)   NOT NULL REFERENCES promo_codes(promo_code),
    redeemed_at   TIMESTAMP     NOT NULL,
    gross_eur     DECIMAL(9,2)  NOT NULL,
    discount_eur  DECIMAL(9,2)  NOT NULL
);
