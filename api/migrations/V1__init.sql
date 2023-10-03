-- Entity => User
CREATE TABLE IF NOT EXISTS tb_users(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    image VARCHAR(255) NOT NULL DEFAULT '',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Entity => Auth
CREATE TABLE IF NOT EXISTS tb_auth (
    user_id UUID NOT NULL UNIQUE REFERENCES tb_users(id),
    access_token VARCHAR(512) NOT NULL,
    refresh_token VARCHAR(512) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Entity => FriendRequest
CREATE TABLE IF NOT EXISTS tb_friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES tb_users(id),
    friend_id UUID NOT NULL REFERENCES tb_users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Entity => Friend
CREATE TABLE IF NOT EXISTS tb_friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES tb_users(id),
    friend_id UUID NOT NULL REFERENCES tb_users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);