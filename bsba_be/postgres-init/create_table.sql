-- ==========================================
-- EXTENSIONS
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS postgis;
-- ==========================================
-- ROLES
-- ==========================================

CREATE TABLE roles (
                       id SERIAL PRIMARY KEY,
                       name VARCHAR(50) UNIQUE NOT NULL
);

-- ==========================================
-- USERS
-- ==========================================

CREATE TABLE users (
                       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255),

                       full_name VARCHAR(255),
                       phone VARCHAR(20),

                       avatar_url VARCHAR(500),

                       auth_provider VARCHAR(50) NOT NULL DEFAULT 'local',

                       role_id INTEGER NOT NULL,

                       is_active BOOLEAN NOT NULL DEFAULT TRUE,

                       created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                       updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                       CONSTRAINT fk_users_role
                           FOREIGN KEY (role_id)
                               REFERENCES roles(id)
);

-- ==========================================
-- STORES
-- ==========================================

CREATE TABLE stores (
                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                        name VARCHAR(255) NOT NULL,

                        description TEXT,

                        address VARCHAR(500),

                        latitude NUMERIC(10,7),
                        longitude NUMERIC(10,7),

                        phone VARCHAR(20),
                        email VARCHAR(255),

                        cover_image_url VARCHAR(500),

                        open_time TIME NOT NULL,
                        close_time TIME NOT NULL,

                        total_capacity INTEGER NOT NULL
                            CHECK (total_capacity > 0),

                        rating_avg NUMERIC(3,2)
                                            DEFAULT 0
                            CHECK (rating_avg >= 0 AND rating_avg <= 5),

                        is_active BOOLEAN NOT NULL DEFAULT TRUE,

                        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- STORE STAFF (which staff answer chats for which store)
-- ==========================================

CREATE TABLE store_staff (
                             id BIGSERIAL PRIMARY KEY,

                             store_id UUID NOT NULL,
                             user_id UUID NOT NULL,

                             created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                             CONSTRAINT uk_store_staff
                                 UNIQUE (store_id, user_id),

                             CONSTRAINT fk_store_staff_store
                                 FOREIGN KEY (store_id)
                                     REFERENCES stores(id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_store_staff_user
                                 FOREIGN KEY (user_id)
                                     REFERENCES users(id)
                                     ON DELETE CASCADE
);

-- ==========================================
-- STORE IMAGES
-- ==========================================

CREATE TABLE store_images (
                              id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                              store_id UUID NOT NULL,

                              image_url VARCHAR(500) NOT NULL,

                              display_order INTEGER DEFAULT 0,

                              created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                              CONSTRAINT fk_store_images_store
                                  FOREIGN KEY (store_id)
                                      REFERENCES stores(id)
                                      ON DELETE CASCADE
);

-- ==========================================
-- BOARD GAMES
-- ==========================================

CREATE TABLE board_games (
                             id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                             name VARCHAR(255) NOT NULL,

                             description TEXT,

                             min_players INTEGER,
                             max_players INTEGER,

                             play_time_minutes INTEGER,

                             age_requirement INTEGER,

                             difficulty_level INTEGER
                                 CHECK (difficulty_level BETWEEN 1 AND 5),

                             image_url VARCHAR(500),

                             category VARCHAR(100),

                             rental_price DECIMAL(10,2),

                             created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- STORE BOARD GAMES
-- ==========================================

CREATE TABLE store_board_games (
                                   id BIGSERIAL PRIMARY KEY,

                                   store_id UUID NOT NULL,
                                   board_game_id UUID NOT NULL,

                                   quantity INTEGER NOT NULL DEFAULT 1
                                       CHECK (quantity >= 0),

                                   CONSTRAINT uq_store_board_game
                                       UNIQUE (store_id, board_game_id),

                                   CONSTRAINT fk_store_board_games_store
                                       FOREIGN KEY (store_id)
                                           REFERENCES stores(id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT fk_store_board_games_game
                                       FOREIGN KEY (board_game_id)
                                           REFERENCES board_games(id)
                                           ON DELETE CASCADE
);

-- ==========================================
-- STORE TIME SLOTS
-- ==========================================

CREATE TABLE store_time_slots (
                                  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                  store_id UUID NOT NULL,

                                  slot_date DATE NOT NULL,

                                  start_time TIME NOT NULL,

                                  end_time TIME NOT NULL,

                                  status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'
                                      CHECK (status IN ('AVAILABLE', 'PENDING', 'CONFIRMED', 'CLOSED', 'CANCELLED')),

                                  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                  CONSTRAINT fk_store_slots_store
                                      FOREIGN KEY (store_id)
                                          REFERENCES stores(id)
                                          ON DELETE CASCADE
);

-- ==========================================
-- BOOKINGS
-- ==========================================

CREATE TABLE bookings (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                          user_id UUID NOT NULL,

                          store_id UUID NOT NULL,

                          slot_id UUID NOT NULL,

                          participant_count INTEGER NOT NULL
                              CHECK (participant_count > 0),

                          total_price NUMERIC(10,2),

                          note TEXT,

                          status VARCHAR(50) NOT NULL DEFAULT 'PENDING'
                              CHECK (
                                  status IN (
                                             'PENDING',
                                             'CONFIRMED',
                                             'CHECKED_IN',
                                             'COMPLETED',
                                             'CANCELLED',
                                             'NO_SHOW'
                                      )
                                  ),

                          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                          CONSTRAINT fk_bookings_user
                              FOREIGN KEY (user_id)
                                  REFERENCES users(id),

                          CONSTRAINT fk_bookings_store
                              FOREIGN KEY (store_id)
                                  REFERENCES stores(id),

                          CONSTRAINT fk_bookings_slot
                              FOREIGN KEY (slot_id)
                                  REFERENCES store_time_slots(id)
);

-- ==========================================
-- REVIEWS
-- ==========================================

CREATE TABLE reviews (
                         id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                         user_id UUID NOT NULL,

                         store_id UUID NOT NULL,

                         booking_id UUID,

                         rating INTEGER NOT NULL
                             CHECK (rating BETWEEN 1 AND 5),

                         comment TEXT,

                         created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                         CONSTRAINT fk_reviews_user
                             FOREIGN KEY (user_id)
                                 REFERENCES users(id),

                         CONSTRAINT fk_reviews_store
                             FOREIGN KEY (store_id)
                                 REFERENCES stores(id),

                         CONSTRAINT fk_reviews_booking
                             FOREIGN KEY (booking_id)
                                 REFERENCES bookings(id)
);

-- ==========================================
-- FAVORITE STORES
-- ==========================================

CREATE TABLE favorite_stores (
                                 id BIGSERIAL PRIMARY KEY,

                                 user_id UUID NOT NULL,
                                 store_id UUID NOT NULL,

                                 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                 CONSTRAINT uq_favorite_store
                                     UNIQUE (user_id, store_id),

                                 CONSTRAINT fk_favorite_user
                                     FOREIGN KEY (user_id)
                                         REFERENCES users(id)
                                         ON DELETE CASCADE,

                                 CONSTRAINT fk_favorite_store
                                     FOREIGN KEY (store_id)
                                         REFERENCES stores(id)
                                         ON DELETE CASCADE
);

-- ==========================================
-- NOTIFICATIONS
-- ==========================================

CREATE TABLE notifications (
                               id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                               user_id UUID NOT NULL,

                               title VARCHAR(255) NOT NULL,

                               body TEXT,

                               type VARCHAR(50),

                               is_read BOOLEAN NOT NULL DEFAULT FALSE,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                               CONSTRAINT fk_notifications_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE
);

-- ==========================================
-- PAYMENTS
-- ==========================================

CREATE TABLE payments (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                          booking_id UUID NOT NULL,
                          user_id UUID NOT NULL,

                          provider VARCHAR(30) NOT NULL
                              CHECK (provider IN ('ZALOPAY')),

                          app_trans_id VARCHAR(40) NOT NULL,
                          zp_trans_token VARCHAR(255),
                          zp_trans_id VARCHAR(100),
                          order_url VARCHAR(1000),

                          amount NUMERIC(19,2) NOT NULL
                              CHECK (amount > 0),

                          status VARCHAR(30) NOT NULL
                              CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELED')),

                          callback_raw_data TEXT,
                          callback_received_at TIMESTAMPTZ,

                          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                          CONSTRAINT fk_payments_booking
                              FOREIGN KEY (booking_id)
                                  REFERENCES bookings(id),

                          CONSTRAINT fk_payments_user
                              FOREIGN KEY (user_id)
                                  REFERENCES users(id)
);

CREATE UNIQUE INDEX uq_payments_app_trans_id ON payments (app_trans_id);
CREATE INDEX idx_payments_booking_id ON payments (booking_id);
CREATE INDEX idx_payments_user_id ON payments (user_id);


CREATE TABLE booking_carts (
                               id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                               user_id UUID NOT NULL UNIQUE,
                               store_id UUID NOT NULL,
                               slot_id UUID,

                               participant_count INTEGER NOT NULL DEFAULT 1,

                               note TEXT,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                               CONSTRAINT fk_cart_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT fk_cart_store
                                   FOREIGN KEY (store_id)
                                       REFERENCES stores(id),

                               CONSTRAINT fk_cart_slot
                                   FOREIGN KEY (slot_id)
                                       REFERENCES store_time_slots(id)
);

CREATE TABLE booking_cart_games (
                                    id BIGSERIAL PRIMARY KEY,

                                    cart_id UUID NOT NULL,
                                    board_game_id UUID NOT NULL,

                                    quantity INTEGER NOT NULL DEFAULT 1,

                                    CONSTRAINT uq_cart_game
                                        UNIQUE(cart_id, board_game_id),

                                    CONSTRAINT fk_cart_game_cart
                                        FOREIGN KEY (cart_id)
                                            REFERENCES booking_carts(id)
                                            ON DELETE CASCADE,

                                    CONSTRAINT fk_cart_game_boardgame
                                        FOREIGN KEY (board_game_id)
                                            REFERENCES board_games(id)
);

CREATE TABLE booking_games (
                               id BIGSERIAL PRIMARY KEY,

                               booking_id UUID NOT NULL,
                               board_game_id UUID NOT NULL,

                               quantity INTEGER NOT NULL DEFAULT 1,

                               CONSTRAINT fk_booking_game_booking
                                   FOREIGN KEY (booking_id)
                                       REFERENCES bookings(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT fk_booking_game_boardgame
                                   FOREIGN KEY (board_game_id)
                                       REFERENCES board_games(id)
);

-- ==========================================
-- CONVERSATIONS
-- ==========================================

CREATE TABLE conversations (
                               id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                               user_id UUID NOT NULL,
                               store_id UUID NOT NULL,

                               last_message_preview TEXT,
                               last_message_at TIMESTAMPTZ,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                               CONSTRAINT uk_conversation_user_store
                                   UNIQUE (user_id, store_id),

                               CONSTRAINT fk_conversations_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT fk_conversations_store
                                   FOREIGN KEY (store_id)
                                       REFERENCES stores(id)
                                       ON DELETE CASCADE
);

-- ==========================================
-- MESSAGES
-- ==========================================

CREATE TABLE messages (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                          conversation_id UUID NOT NULL,
                          sender_id UUID,

                          sender_type VARCHAR(50),

                          content TEXT,

                          type VARCHAR(50) NOT NULL DEFAULT 'TEXT',

                          is_read BOOLEAN NOT NULL DEFAULT FALSE,

                          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                          CONSTRAINT fk_messages_conversation
                              FOREIGN KEY (conversation_id)
                                  REFERENCES conversations(id)
                                  ON DELETE CASCADE,

                          CONSTRAINT fk_messages_sender
                              FOREIGN KEY (sender_id)
                                  REFERENCES users(id)
                                  ON DELETE SET NULL
);

CREATE INDEX idx_messages_conversation
    ON messages (conversation_id, created_at);

ALTER TABLE stores
    ADD COLUMN location GEOGRAPHY(Point, 4326)
GENERATED ALWAYS AS (
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
) STORED;

CREATE INDEX idx_stores_location
    ON stores
    USING GIST (location);
