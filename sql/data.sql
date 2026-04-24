/* =========================================================
   STORAGE BUCKETS
========================================================= */

INSERT INTO storage.buckets (id, name)
VALUES ('avatars', 'avatars');

INSERT INTO storage.buckets (id, name)
VALUES ('review_bucket', 'review_bucket');


/* =========================================================
   STORAGE POLICIES
========================================================= */

-- Avatars
CREATE POLICY "Avatar images are publicly accessible."
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Anyone can upload an avatar."
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatars');

-- Review Images
CREATE POLICY "Review images are publicly accessible."
ON storage.objects FOR SELECT
USING (bucket_id = 'review_bucket');

CREATE POLICY "Anyone can upload a review image."
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'review_bucket');


/* =========================================================
   CATEGORIES TABLE
========================================================= */

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by everyone"
ON categories FOR SELECT USING (true);


/* =========================================================
   PRODUCTS TABLE
========================================================= */

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    author_id UUID NOT NULL
        REFERENCES auth.users(id) ON DELETE CASCADE,

    sizes TEXT[],
    colors TEXT[],
    styles TEXT[],

    brand TEXT,

    image_url_array TEXT[] NOT NULL,
    video_url_array TEXT[] DEFAULT ARRAY[]::TEXT[],

    name TEXT NOT NULL,

    category UUID NOT NULL
        REFERENCES categories(id),

    price NUMERIC(10,2) NOT NULL,

    description TEXT,
    discount NUMERIC(5,2) DEFAULT 0,

    quantity INTEGER NOT NULL,
    product_shipping_fee INTEGER,
    offer_price NUMERIC(10,2),

    location TEXT,
    product_comment TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by everyone"
ON products FOR SELECT USING (true);


/* =========================================================
   ORDERS TABLE  (IMPORTANT: BEFORE REVIEWS)
========================================================= */

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id),

    user_email TEXT,

    product_name TEXT NOT NULL,
    product_category TEXT,

    amount_paid NUMERIC(10,2) NOT NULL,
    reference_paystack TEXT NOT NULL,

    quantity_bought INTEGER NOT NULL,
    image_url TEXT NOT NULL,

    status TEXT NOT NULL CHECK (
        status IN (
            'processing', 'completed', 'cancelled',
            'shipped', 'delivered', 'returned',
            'waiting', 'reviewed'
        )
    ),

    size TEXT,
    color TEXT,

    region TEXT,
    state TEXT,
    city TEXT,
    address TEXT NOT NULL,

    phone TEXT NOT NULL,
    country_code TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by User"
ON orders FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
ON orders FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON orders FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own data"
ON orders FOR DELETE
USING (auth.uid() = user_id);


/* =========================================================
   REVIEWS TABLE (AFTER ORDERS)
========================================================= */

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL UNIQUE
        REFERENCES orders(id) ON DELETE CASCADE,

    user_id UUID NOT NULL
        REFERENCES auth.users(id) ON DELETE CASCADE,

    review_images TEXT[],
    review_title TEXT,
    review_description TEXT,

    product_rating NUMERIC DEFAULT 5,
    delivery_rating NUMERIC DEFAULT 5,

    product_image_url TEXT,
    product_name TEXT,
    amount_paid NUMERIC,
    the_quantity INT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by User"
ON reviews FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
ON reviews FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON reviews FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own data"
ON reviews FOR DELETE
USING (auth.uid() = user_id);


/* =========================================================
   ADDRESS TABLE
========================================================= */

CREATE TABLE address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id) ON DELETE CASCADE,

    title TEXT,
    region TEXT DEFAULT 'Nigeria',

    address TEXT,
    state TEXT,
    city TEXT,

    phone TEXT,
    country_code TEXT,
    flag TEXT,

    is_default BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE address ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by User"
ON address FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
ON address FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON address FOR UPDATE
USING (auth.uid() = user_id);


/* =========================================================
   ADDRESS TRIGGER (ONLY ONE DEFAULT)
========================================================= */

CREATE OR REPLACE FUNCTION enforce_single_default_address()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE address
    SET is_default = FALSE
    WHERE user_id = NEW.user_id
      AND id <> NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_default_address_set
AFTER UPDATE ON address
FOR EACH ROW
WHEN (NEW.is_default = TRUE)
EXECUTE FUNCTION enforce_single_default_address();


/* =========================================================
   ELDICS USERS TABLE
========================================================= */

CREATE TABLE eldics_users (
    id UUID PRIMARY KEY
        REFERENCES auth.users(id) ON DELETE CASCADE,

    full_name TEXT,
    avatar_url TEXT,
    username TEXT,

    email TEXT UNIQUE,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT username_length
        CHECK (char_length(username) >= 3)
);

ALTER TABLE eldics_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Readable by everyone"
ON eldics_users FOR SELECT USING (true);

CREATE POLICY "Users can insert their own data"
ON eldics_users FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own data"
ON eldics_users FOR UPDATE
USING (auth.uid() = id);


/* =========================================================
   AUTH TRIGGERS
========================================================= */

-- Sync email
CREATE FUNCTION public.updating_auth_user_email()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE auth.users
    SET email = NEW.email
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_eldics_users_email_update
AFTER UPDATE ON public.eldics_users
FOR EACH ROW
WHEN (OLD.email IS DISTINCT FROM NEW.email)
EXECUTE FUNCTION public.updating_auth_user_email();


-- Handle new user
CREATE FUNCTION public.handling_new_user()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.raw_user_meta_data->>'avatar_url' IS NULL
       OR NEW.raw_user_meta_data->>'avatar_url' = '' THEN

        NEW.raw_user_meta_data :=
            jsonb_set(
                NEW.raw_user_meta_data,
                '{avatar_url}',
                '"https://thfywnuxkivlmokxzbyp.supabase.co/storage/v1/object/public/temp1//user.png"'::jsonb
            );
    END IF;

    INSERT INTO public.eldics_users (id, email, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'avatar_url'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_the_auth_user_verified
AFTER UPDATE ON auth.users
FOR EACH ROW
WHEN (
    OLD.email_confirmed_at IS NULL
    AND NEW.email_confirmed_at IS NOT NULL
)
EXECUTE FUNCTION public.handling_new_user();