-- ==========================================
-- SEED DATA (BSBA - Board Space Booking Application)
-- Runs automatically AFTER create_table.sql on a fresh Postgres volume
-- (postgres-init scripts execute in alphabetical order).
-- All UUIDs are fixed/deterministic so foreign keys stay wired across runs.
-- Local login password for all seeded users: Password@123
-- ==========================================

-- ------------------------------------------
-- ROLES
-- ------------------------------------------
INSERT INTO roles (id, name) VALUES
    (1, 'ADMIN'),
    (2, 'CUSTOMER'),
    (3, 'STAFF')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('roles', 'id'), (SELECT MAX(id) FROM roles));

-- ------------------------------------------
-- USERS
-- ------------------------------------------
INSERT INTO users (id, email, password_hash, full_name, phone, avatar_url, auth_provider, role_id, is_active) VALUES
    ('a0000000-0000-0000-0000-000000000002', 'customer01@gmail.com', crypt('Password@123', gen_salt('bf', 10)), 'Customer One',   '0901000001', 'https://i.pravatar.cc/150?img=12', 'local', 2, TRUE),
    ('a0000000-0000-0000-0000-000000000003', 'customer02@gmail.com', crypt('Password@123', gen_salt('bf', 10)), 'Customer Two',   '0901000002', 'https://i.pravatar.cc/150?img=20', 'local', 2, TRUE),
    ('a0000000-0000-0000-0000-000000000004', 'customer03@gmail.com', crypt('Password@123', gen_salt('bf', 10)), 'Customer Three', '0901000003', 'https://i.pravatar.cc/150?img=33', 'local', 2, TRUE),
    ('a0000000-0000-0000-0000-000000000005', 'staff01@gmail.com',    crypt('Password@123', gen_salt('bf', 10)), 'Staff One',      '0902000001', 'https://i.pravatar.cc/150?img=51', 'local', 3, TRUE),
    ('a0000000-0000-0000-0000-000000000006', 'staff02@gmail.com',    crypt('Password@123', gen_salt('bf', 10)), 'Staff Two',      '0902000002', 'https://i.pravatar.cc/150?img=52', 'local', 3, TRUE)
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- STORES
-- ------------------------------------------
INSERT INTO stores (
    id, name, description, address, latitude, longitude,
    phone, email, cover_image_url,
    open_time, close_time,
    total_capacity, charge_fee, rating_avg, is_active
) VALUES
      ('b0000000-0000-0000-0000-000000000001', 'BoardNest Cau Giay', 'Cozy board-game cafe near the university with 40+ titles and great coffee.', '123 Cau Giay, Ha Noi', 21.0313000, 105.7964000, '0241111001', 'caugiay@boardnest.com', 'https://picsum.photos/seed/store1/800/400', '08:00:00', '22:00:00', 60, 30000.0, 4.50, TRUE),
      ('b0000000-0000-0000-0000-000000000002', 'BoardNest District 1', 'Spacious downtown venue, perfect for big groups and tournaments.', '45 Le Loi, District 1, HCMC', 10.7725000, 106.6980000, '0282222002', 'd1@boardnest.com', 'https://picsum.photos/seed/store2/800/400', '09:00:00', '23:00:00', 80, 45000.0, 4.20, TRUE),
      ('b0000000-0000-0000-0000-000000000003', 'BoardNest Da Nang', 'Beachside game lounge with a quiet strategy room and a party zone.', '88 Bach Dang, Da Nang', 16.0678000, 108.2208000, '0236333003', 'danang@boardnest.com', 'https://picsum.photos/seed/store3/800/400', '10:00:00', '22:00:00', 50, 35000.0, 4.80, TRUE)
    ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- STORE IMAGES
-- ------------------------------------------
INSERT INTO store_images (id, store_id, image_url, display_order) VALUES
    ('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'https://picsum.photos/seed/store1a/600/400', 0),
    ('c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'https://picsum.photos/seed/store1b/600/400', 1),
    ('c0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'https://picsum.photos/seed/store2a/600/400', 0),
    ('c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000002', 'https://picsum.photos/seed/store2b/600/400', 1),
    ('c0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000003', 'https://picsum.photos/seed/store3a/600/400', 0)
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- BOARD GAMES
-- ------------------------------------------
INSERT INTO board_games (id, name, description, min_players, max_players, play_time_minutes, age_requirement, difficulty_level, image_url, category, rental_price) VALUES
    ('d0000000-0000-0000-0000-000000000001', 'Catan',              'Trade, build and settle the island of Catan.',                    3, 4,  90,  10, 2, 'https://picsum.photos/seed/game1/300/300', 'Strategy', 30000.00),
    ('d0000000-0000-0000-0000-000000000002', 'Ticket to Ride',     'Collect train cards and claim railway routes across the map.',     2, 5,  60,   8, 2, 'https://picsum.photos/seed/game2/300/300', 'Family',   25000.00),
    ('d0000000-0000-0000-0000-000000000003', 'Pandemic',           'Cooperate to stop four diseases from spreading worldwide.',        2, 4,  45,   8, 3, 'https://picsum.photos/seed/game3/300/300', 'Co-op',    28000.00),
    ('d0000000-0000-0000-0000-000000000004', 'Carcassonne',        'Place tiles and meeples to build a medieval landscape.',          2, 5,  45,   7, 2, 'https://picsum.photos/seed/game4/300/300', 'Family',   22000.00),
    ('d0000000-0000-0000-0000-000000000005', 'Wingspan',           'A relaxing engine-builder about attracting birds to reserves.',    1, 5,  70,  10, 3, 'https://picsum.photos/seed/game5/300/300', 'Strategy', 35000.00),
    ('d0000000-0000-0000-0000-000000000006', 'Codenames',          'Give one-word clues to identify your team''s secret agents.',     4, 8,  20,  10, 1, 'https://picsum.photos/seed/game6/300/300', 'Party',    15000.00),
    ('d0000000-0000-0000-0000-000000000007', 'Splendor',           'Collect gems and build a Renaissance jewel empire.',              2, 4,  30,  10, 2, 'https://picsum.photos/seed/game7/300/300', 'Strategy', 20000.00),
    ('d0000000-0000-0000-0000-000000000008', 'Terraforming Mars',  'Compete to make Mars habitable in this deep engine-builder.',      1, 5, 120,  12, 4, 'https://picsum.photos/seed/game8/300/300', 'Strategy', 45000.00)
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- STORE BOARD GAMES (inventory per store)
-- ------------------------------------------
INSERT INTO store_board_games (store_id, board_game_id, quantity) VALUES
    ('b0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 3),
    ('b0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 2),
    ('b0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000003', 2),
    ('b0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000006', 4),
    ('b0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 2),
    ('b0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000005', 2),
    ('b0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000007', 3),
    ('b0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000008', 1),
    ('b0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000004', 2),
    ('b0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000005', 1),
    ('b0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000006', 3)
ON CONFLICT (store_id, board_game_id) DO NOTHING;

-- ------------------------------------------
-- STORE TIME SLOTS (today + next 2 days)
-- ------------------------------------------
INSERT INTO store_time_slots (id, store_id, slot_date, start_time, end_time, status) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', CURRENT_DATE,     '09:00', '11:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', CURRENT_DATE,     '14:00', '16:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', CURRENT_DATE,     '19:00', '21:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000002', CURRENT_DATE,     '10:00', '12:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000002', CURRENT_DATE + 1, '15:00', '17:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000002', CURRENT_DATE + 1, '18:00', '20:00', 'CLOSED'),
    ('e0000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000003', CURRENT_DATE,     '13:00', '15:00', 'AVAILABLE'),
    ('e0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000003', CURRENT_DATE + 2, '16:00', '18:00', 'AVAILABLE')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- BOOKINGS
-- ------------------------------------------
INSERT INTO bookings (id, user_id, store_id, slot_id, participant_count, total_price, note, status) VALUES
    ('f0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 4, 60000.00, 'Birthday meetup, please prepare Catan.', 'COMPLETED'),
    ('f0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000004', 2, 45000.00, NULL,                                     'CONFIRMED'),
    ('f0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000007', 6, 15000.00, 'Party night with friends.',              'PENDING'),
    ('f0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 3, 28000.00, NULL,                                     'CANCELLED')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- BOOKING GAMES (games chosen per booking)
-- ------------------------------------------
INSERT INTO booking_games (booking_id, board_game_id, quantity) VALUES
    ('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 1),
    ('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000006', 1),
    ('f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000007', 1),
    ('f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000006', 1),
    ('f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000003', 1);

-- ------------------------------------------
-- PAYMENTS
-- ------------------------------------------
INSERT INTO payments (
    id, booking_id, user_id, provider, app_trans_id,
    zp_trans_token, zp_trans_id, order_url, amount, status,
    callback_raw_data, callback_received_at, created_at, updated_at
) VALUES
    (
        '10000000-0000-0000-0000-000000000001',
        'f0000000-0000-0000-0000-000000000001',
        'a0000000-0000-0000-0000-000000000002',
        'ZALOPAY', '260610_seed0001',
        'seed-zp-trans-token-0001', '260610000000001', NULL,
        60000.00, 'SUCCESS', NULL,
        NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'
    ),
    (
        '10000000-0000-0000-0000-000000000002',
        'f0000000-0000-0000-0000-000000000002',
        'a0000000-0000-0000-0000-000000000003',
        'ZALOPAY', '260611_seed0002',
        'seed-zp-trans-token-0002', '260611000000002', NULL,
        45000.00, 'SUCCESS', NULL,
        NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        'f0000000-0000-0000-0000-000000000003',
        'a0000000-0000-0000-0000-000000000004',
        'ZALOPAY', '260612_seed0003',
        'seed-zp-trans-token-0003', NULL, NULL,
        15000.00, 'PENDING', NULL,
        NULL, NOW(), NOW()
    ),
    (
        '10000000-0000-0000-0000-000000000004',
        'f0000000-0000-0000-0000-000000000004',
        'a0000000-0000-0000-0000-000000000004',
        'ZALOPAY', '260609_seed0004',
        NULL, NULL, NULL,
        28000.00, 'CANCELED', NULL,
        NULL, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'
    )
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- REVIEWS
-- ------------------------------------------
INSERT INTO reviews (id, user_id, store_id, booking_id, rating, comment) VALUES
    ('20000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 5, 'Amazing place, the staff explained the rules really well!'),
    ('20000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', NULL,                                   4, 'Great selection of games, a bit noisy on weekends.'),
    ('20000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', NULL,                                   5, 'Best board game cafe in Da Nang. Highly recommend.')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- FAVORITE STORES
-- ------------------------------------------
INSERT INTO favorite_stores (user_id, store_id) VALUES
    ('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001'),
    ('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003'),
    ('a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002'),
    ('a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003')
ON CONFLICT (user_id, store_id) DO NOTHING;

-- ------------------------------------------
-- NOTIFICATIONS
-- ------------------------------------------
INSERT INTO notifications (id, user_id, title, body, type, is_read) VALUES
    ('30000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'Booking confirmed',  'Your booking at BoardNest Cau Giay is confirmed for today 09:00.', 'booking', TRUE),
    ('30000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'Payment received',   'We received your payment of 45,000 VND.',                          'payment', FALSE),
    ('30000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'Booking pending',    'Your booking is awaiting store confirmation.',                     'booking', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------
-- BOOKING CARTS (active cart per user)
-- ------------------------------------------
INSERT INTO booking_carts (id, user_id, store_id, slot_id, participant_count, note) VALUES
    ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000005', 4, 'Planning a Wingspan session.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO booking_cart_games (cart_id, board_game_id, quantity) VALUES
    ('40000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000005', 1),
    ('40000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000007', 1)
ON CONFLICT (cart_id, board_game_id) DO NOTHING;

-- ------------------------------------------
-- CONVERSATIONS (user <-> store chat)
-- ------------------------------------------
INSERT INTO conversations (id, user_id, store_id, last_message_preview, last_message_at) VALUES
    ('50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'Great, see you at 9!',            NOW() - INTERVAL '2 hours'),
    ('50000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'Do you have Wingspan available?', NOW() - INTERVAL '30 minutes')
ON CONFLICT (user_id, store_id) DO NOTHING;

-- ------------------------------------------
-- MESSAGES
-- sender_type: CUSTOMER | STAFF | SYSTEM ; type: TEXT | IMAGE | GAME_CARD | SYSTEM
-- ------------------------------------------
INSERT INTO messages (id, conversation_id, sender_id, sender_type, content, type, is_read, created_at) VALUES
    ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'CUSTOMER', 'Hi, is Catan available this morning?', 'TEXT', TRUE,  NOW() - INTERVAL '3 hours'),
    ('60000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000006', 'STAFF',    'Yes! We have 3 copies. Want me to reserve one?', 'TEXT', TRUE,  NOW() - INTERVAL '2 hours 30 minutes'),
    ('60000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'CUSTOMER', 'Yes please, for 4 people at 9am.',     'TEXT', TRUE,  NOW() - INTERVAL '2 hours 15 minutes'),
    ('60000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000006', 'STAFF',    'Great, see you at 9!',                 'TEXT', TRUE,  NOW() - INTERVAL '2 hours'),
    ('60000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'CUSTOMER', 'Do you have Wingspan available?',       'TEXT', FALSE, NOW() - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;


INSERT INTO store_staff (id, created_at, user_id, store_id) VALUES
    (1, now(), 'a0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000001'),
    (2, now(), 'a0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000001')
ON CONFLICT (store_id, user_id) DO NOTHING;
