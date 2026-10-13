-- ==============================================================================
-- PARKING PLATFORM DATABASE SCHEMA (SUPABASE)
-- ==============================================================================

-- 1. PROFILES (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  role TEXT CHECK (role IN ('vehicle_owner', 'parking_owner', 'admin')) DEFAULT 'vehicle_owner',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. VEHICLES
CREATE TABLE IF NOT EXISTS public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  plate TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PARKING LOTS
CREATE TABLE IF NOT EXISTS public.parking_lots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude DECIMAL NOT NULL,
  longitude DECIMAL NOT NULL,
  price_per_hour DECIMAL NOT NULL,
  opening_time TIME,
  closing_time TIME,
  status TEXT CHECK (status IN ('active', 'inactive', 'maintenance')) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PARKING SPACES
CREATE TABLE IF NOT EXISTS public.parking_spaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  space_number TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  status TEXT CHECK (status IN ('available', 'occupied', 'maintenance', 'inactive')) DEFAULT 'available'
);

-- 5. PARKING SCHEDULES
CREATE TABLE IF NOT EXISTS public.parking_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6) NOT NULL,
  opening_time TIME NOT NULL,
  closing_time TIME NOT NULL,
  is_open BOOLEAN DEFAULT true NOT NULL
);

-- 6. RESERVATIONS
CREATE TABLE IF NOT EXISTS public.reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  parking_space_id UUID REFERENCES public.parking_spaces(id) ON DELETE RESTRICT NOT NULL,
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE RESTRICT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status TEXT CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')) DEFAULT 'pending' NOT NULL,
  total_price DECIMAL NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PAYMENTS
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID REFERENCES public.reservations(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL NOT NULL,
  payment_method TEXT,
  transaction_id TEXT,
  status TEXT CHECK (status IN ('pending', 'approved', 'rejected', 'refunded')) DEFAULT 'pending' NOT NULL,
  paid_at TIMESTAMPTZ
);

-- 8. REVIEWS
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  reservation_id UUID REFERENCES public.reservations(id) ON DELETE CASCADE UNIQUE NOT NULL,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. FAVORITES
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_user_parking_favorite UNIQUE(user_id, parking_lot_id)
);

-- 10. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT,
  is_read BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. AI CONVERSATIONS
CREATE TABLE IF NOT EXISTS public.ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. AI MESSAGES
CREATE TABLE IF NOT EXISTS public.ai_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES public.ai_conversations(id) ON DELETE CASCADE NOT NULL,
  sender TEXT CHECK (sender IN ('user', 'ai')) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. RECOMMENDATION EVENTS (ML)
CREATE TABLE IF NOT EXISTS public.recommendation_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  parking_lot_id UUID REFERENCES public.parking_lots(id) ON DELETE CASCADE NOT NULL,
  event_type TEXT CHECK (event_type IN ('view', 'search', 'favorite', 'reservation', 'rating')) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. SECURITY EVENTS
CREATE TABLE IF NOT EXISTS public.security_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  device_info TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- AUTOMATIC PROFILE CREATION TRIGGER
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'vehicle_owner')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_lots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;

-- Base RLS Policies
-- Profiles: Users can read and update their own profile
CREATE POLICY "Users can read own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Vehicles: Users can manage their own vehicles
CREATE POLICY "Users manage own vehicles" ON public.vehicles FOR ALL USING (auth.uid() = user_id);

-- Parking Lots: Public can view active parking lots, owners can manage theirs
CREATE POLICY "Public can view active parking lots" ON public.parking_lots FOR SELECT USING (status = 'active');
CREATE POLICY "Owners manage own parking lots" ON public.parking_lots FOR ALL USING (auth.uid() = owner_id);

-- Spaces & Schedules: Public can view, owner of parking lot can manage
CREATE POLICY "Public can view parking spaces" ON public.parking_spaces FOR SELECT USING (true);
CREATE POLICY "Owners manage parking spaces" ON public.parking_spaces FOR ALL USING (
  EXISTS (SELECT 1 FROM public.parking_lots WHERE id = parking_spaces.parking_lot_id AND owner_id = auth.uid())
);

CREATE POLICY "Public can view schedules" ON public.parking_schedules FOR SELECT USING (true);
CREATE POLICY "Owners manage schedules" ON public.parking_schedules FOR ALL USING (
  EXISTS (SELECT 1 FROM public.parking_lots WHERE id = parking_schedules.parking_lot_id AND owner_id = auth.uid())
);

-- Reservations: Users can see their own reservations, owners can see reservations on their parking lots
CREATE POLICY "Users can view own reservations" ON public.reservations FOR SELECT USING (
  auth.uid() = user_id OR
  EXISTS (SELECT 1 FROM public.parking_lots WHERE id = reservations.parking_lot_id AND owner_id = auth.uid())
);
CREATE POLICY "Users can create reservations" ON public.reservations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users and owners update reservations" ON public.reservations FOR UPDATE USING (
  auth.uid() = user_id OR
  EXISTS (SELECT 1 FROM public.parking_lots WHERE id = reservations.parking_lot_id AND owner_id = auth.uid())
);

-- Reviews: Public can view reviews, users can insert for their own reservations
CREATE POLICY "Public can view reviews" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users create own reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Favorites: Users manage their favorites
CREATE POLICY "Users manage own favorites" ON public.favorites FOR ALL USING (auth.uid() = user_id);

-- Notifications: Users manage their notifications
CREATE POLICY "Users manage own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);
