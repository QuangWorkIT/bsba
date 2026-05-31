-- ==========================================
-- EXTENSIONS
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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

                                  status VARCHAR(20) NOT NULL DEFAULT 'available'
                                      CHECK (status IN ('available', 'closed', 'cancelled')),

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

                          status VARCHAR(50) NOT NULL DEFAULT 'pending'
                              CHECK (
                                  status IN (
                                             'pending',
                                             'confirmed',
                                             'checked_in',
                                             'completed',
                                             'cancelled',
                                             'no_show'
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

                          amount NUMERIC(10,2) NOT NULL,

                          payment_method VARCHAR(50),

                          payment_status VARCHAR(50),

                          transaction_code VARCHAR(255),

                          paid_at TIMESTAMPTZ,

                          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                          CONSTRAINT fk_payments_booking
                              FOREIGN KEY (booking_id)
                                  REFERENCES bookings(id)
);