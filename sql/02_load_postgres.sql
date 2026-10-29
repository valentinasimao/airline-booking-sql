-- Load the CSV sample data (PostgreSQL, run with psql from the repository root).
\copy airports          FROM 'data/airports.csv'          CSV HEADER
\copy aircraft_types    FROM 'data/aircraft_types.csv'    CSV HEADER
\copy seat_map          FROM 'data/seat_map.csv'          CSV HEADER
\copy flights           FROM 'data/flights.csv'           CSV HEADER
\copy passengers        FROM 'data/passengers.csv'        CSV HEADER
\copy bookings          FROM 'data/bookings.csv'          CSV HEADER
\copy tickets           FROM 'data/tickets.csv'           CSV HEADER
\copy seat_assignments  FROM 'data/seat_assignments.csv'  CSV HEADER
\copy upgrade_requests  FROM 'data/upgrade_requests.csv'  CSV HEADER
\copy checkout_sessions FROM 'data/checkout_sessions.csv' CSV HEADER
\copy payments          FROM 'data/payments.csv'          CSV HEADER
\copy refunds           FROM 'data/refunds.csv'           CSV HEADER
