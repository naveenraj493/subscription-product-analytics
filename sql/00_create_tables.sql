CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    device VARCHAR(20) NOT NULL,
    pre_engagement_7d INTEGER NOT NULL
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    plan VARCHAR(20) NOT NULL,
    monthly_price NUMERIC(10,2) NOT NULL,
    trial_start_date DATE NOT NULL,
    paid_start_date DATE,
    end_date DATE,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE experiment_assignment (
    user_id INTEGER PRIMARY KEY,
    experiment VARCHAR(100) NOT NULL,
    variant VARCHAR(10) NOT NULL,
    assignment_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);