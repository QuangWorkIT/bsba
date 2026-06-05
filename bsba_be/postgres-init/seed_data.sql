-- ==========================================
-- SEED ROLES
-- ==========================================
INSERT INTO roles (id, name) VALUES
(1, 'USER'),
(2, 'ADMIN')
ON CONFLICT (name) DO NOTHING;

-- Reset SERIAL sequence for roles
SELECT setval(pg_get_serial_sequence('roles', 'id'), COALESCE(MAX(id), 1)) FROM roles;

-- ==========================================
-- SEED USERS
-- Password for both users is 'password' (hashed with BCrypt)
-- ==========================================
INSERT INTO users (id, email, password_hash, full_name, phone, auth_provider, role_id, is_active) VALUES
('10000000-0000-0000-0000-000000000001', 'admin@bsba.com', '$2a$10$XwZq9Zv2R4Tmlkh9P0gApepq42z2EcFTNsKF6aSw8/jpL4GKwZDfu', 'System Administrator', '0123456789', 'local', 2, TRUE),
('10000000-0000-0000-0000-000000000002', 'user@bsba.com', '$2a$10$XwZq9Zv2R4Tmlkh9P0gApepq42z2EcFTNsKF6aSw8/jpL4GKwZDfu', 'Regular User', '0987654321', 'local', 1, TRUE)
ON CONFLICT (email) DO NOTHING;

-- ==========================================
-- SEED STORES
-- ==========================================
INSERT INTO stores (id, name, description, address, latitude, longitude, phone, email, cover_image_url, total_capacity, rating_avg, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'The Dice Castle HCMC', 'A premium board game cafe with over 500+ game selections, serving specialty coffee and mocktails.', '456 Nguyen Hue, District 1, Ho Chi Minh City', 10.775673, 106.700424, '02812345678', 'contact@dicecastle.vn', 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09', 40, 4.9, TRUE),
('20000000-0000-0000-0000-000000000002', 'Meeple Lounge Hanoi', 'Relaxed space perfect for casual gamers, family gatherings, and competitive tournaments.', '12 Ly Thuong Kiet, Hoan Kiem, Hanoi', 21.028511, 105.852447, '02487654321', 'hello@meeplelounge.vn', 'https://images.unsplash.com/photo-1511512578047-dfb367046420', 30, 4.5, TRUE)
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- SEED STORE IMAGES
-- ==========================================
INSERT INTO store_images (id, store_id, image_url, display_order) VALUES
('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09', 1),
('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1585504198199-20277593b94f', 2),
('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1511512578047-dfb367046420', 1)
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- SEED BOARD GAMES
-- ==========================================
INSERT INTO board_games (id, name, description, min_players, max_players, play_time_minutes, age_requirement, difficulty_level, image_url) VALUES
('40000000-0000-0000-0000-000000000001', 'Settlers of Catan', 'Collect resources and build roads, settlements, and cities to rule the island of Catan.', 3, 4, 90, 10, 2, 'https://images.unsplash.com/photo-1606167668584-78701c57f13d'),
('40000000-0000-0000-0000-000000000002', 'Ticket to Ride', 'A cross-country train adventure game where players collect train cards to claim railway routes.', 2, 5, 60, 8, 2, 'https://images.unsplash.com/photo-1611195974226-a6a9be9dd763'),
('40000000-0000-0000-0000-000000000003', 'Carcassonne', 'A tile-placement game where players draw and place tiles to build cities, roads, monasteries, and fields.', 2, 5, 45, 7, 2, 'https://images.unsplash.com/photo-1585504198199-20277593b94f'),
('40000000-0000-0000-0000-000000000004', 'Exploding Kittens', 'A highly-strategic, kitty-powered version of Russian Roulette.', 2, 5, 15, 7, 1, 'https://images.unsplash.com/photo-1606167668584-78701c57f13d')
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- SEED STORE BOARD GAMES
-- ==========================================
INSERT INTO store_board_games (store_id, board_game_id, quantity) VALUES
('20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 3),
('20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000002', 2),
('20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000004', 5),
('20000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 2),
('20000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000003', 4)
ON CONFLICT (store_id, board_game_id) DO NOTHING;

-- ==========================================
-- SEED STORE TIME SLOTS
-- Seeding slots for the current date & next days
-- ==========================================
INSERT INTO store_time_slots (id, store_id, slot_date, start_time, end_time, status) VALUES
('50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', CURRENT_DATE, '09:00:00', '13:00:00', 'available'),
('50000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', CURRENT_DATE, '13:30:00', '17:30:00', 'available'),
('50000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', CURRENT_DATE, '18:00:00', '22:00:00', 'available'),
('50000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', CURRENT_DATE, '10:00:00', '14:00:00', 'available'),
('50000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', CURRENT_DATE, '15:00:00', '19:00:00', 'available')
ON CONFLICT (id) DO NOTHING;
