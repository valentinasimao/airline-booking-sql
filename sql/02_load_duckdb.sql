-- Load the CSV sample data (DuckDB). Run from the repository root.
COPY airports          FROM 'data/airports.csv'          (HEADER);
COPY aircraft_types    FROM 'data/aircraft_types.csv'    (HEADER);
COPY seat_map          FROM 'data/seat_map.csv'          (HEADER);
COPY flights           FROM 'data/flights.csv'           (HEADER);
COPY passengers        FROM 'data/passengers.csv'        (HEADER);
COPY bookings          FROM 'data/bookings.csv'          (HEADER);
COPY tickets           FROM 'data/tickets.csv'           (HEADER);
COPY seat_assignments  FROM 'data/seat_assignments.csv'  (HEADER);
COPY upgrade_requests  FROM 'data/upgrade_requests.csv'  (HEADER);
COPY checkout_sessions FROM 'data/checkout_sessions.csv' (HEADER);
COPY payments          FROM 'data/payments.csv'          (HEADER);
COPY refunds           FROM 'data/refunds.csv'           (HEADER);
COPY promo_codes        FROM 'data/promo_codes.csv'        (HEADER);
COPY booking_promotions FROM 'data/booking_promotions.csv' (HEADER);
