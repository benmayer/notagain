# NotAgain Supabase Database Schema

This document describes the Supabase PostgreSQL database schema required for the NotAgain app.

## Overview

The database consists of 5 main tables for managing user authentication, profiles, blocking rules, usage tracking, and analytics.

## Tables

### 1. `profiles`
Extends Supabase's built-in `auth.users` table with additional user profile data.

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

### 2. `blocking_rules`
Stores the blocking rules created by users to control app/website access.

```sql
CREATE TABLE blocking_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  app_name TEXT NOT NULL,
  app_bundle_id TEXT,
  enabled BOOLEAN DEFAULT true,
  schedule TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX blocking_rules_user_id_idx ON blocking_rules(user_id);
CREATE INDEX blocking_rules_created_at_idx ON blocking_rules(created_at DESC);

-- Enable RLS
ALTER TABLE blocking_rules ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own rules"
  ON blocking_rules FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create rules"
  ON blocking_rules FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own rules"
  ON blocking_rules FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own rules"
  ON blocking_rules FOR DELETE
  USING (auth.uid() = user_id);
```

### 3. `app_usage`
Tracks daily app usage time for analytics and reporting.

```sql
CREATE TABLE app_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  app_name TEXT NOT NULL,
  duration_seconds INTEGER NOT NULL DEFAULT 0,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, app_name, date)
);

-- Indexes
CREATE INDEX app_usage_user_id_idx ON app_usage(user_id);
CREATE INDEX app_usage_date_idx ON app_usage(date DESC);

-- Enable RLS
ALTER TABLE app_usage ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own usage"
  ON app_usage FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can log usage"
  ON app_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their usage"
  ON app_usage FOR UPDATE
  USING (auth.uid() = user_id);
```

### 4. `blocked_attempts`
Logs each time a user attempts to access a blocked app (for analytics and audit trail).

```sql
CREATE TABLE blocked_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rule_id UUID NOT NULL REFERENCES blocking_rules(id) ON DELETE CASCADE,
  app_name TEXT NOT NULL,
  blocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX blocked_attempts_user_id_idx ON blocked_attempts(user_id);
CREATE INDEX blocked_attempts_blocked_at_idx ON blocked_attempts(blocked_at DESC);

-- Enable RLS
ALTER TABLE blocked_attempts ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own blocked attempts"
  ON blocked_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can log blocked attempts"
  ON blocked_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Setup Instructions

### 1. Create Tables
Copy the SQL above and run it in the Supabase SQL Editor:
- Go to your Supabase project dashboard
- Navigate to SQL Editor
- Create a new query
- Paste the SQL above
- Run the query

### 2. Enable Row Level Security (RLS)
RLS is already enabled in the SQL above. Verify in the Supabase dashboard:
- Go to Authentication → Policies
- Confirm all tables have policies attached

### 3. Create Service Role (Optional)
For server-side operations:
```sql
-- Create a role for backend operations
CREATE ROLE service_role WITH NOLOGIN;
GRANT USAGE ON SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO service_role;
```

## Data Flow

```
User Registration
  ↓
  Creates: auth.users entry + profiles row
  
Create Blocking Rule
  ↓
  Inserts: blocking_rules row
  
User Opens App
  ↓
  Logs: app_usage (daily duration aggregation)
  
User Attempts Blocked App
  ↓
  Logs: blocked_attempts (for audit trail)
```

## Notes

- **UNIQUE constraint** on `app_usage(user_id, app_name, date)` ensures one record per app per day per user
- **Cascading deletes** ensure when a user is deleted, all related data is cleaned up
- **Row Level Security** ensures users can only access their own data
- **Indexes** on `user_id` and date fields improve query performance for reports

## Scaling Considerations

- For high-volume apps, consider archiving old `blocked_attempts` to a separate table
- Add partitioning to `app_usage` by date for faster queries on historical data
- Monitor query performance and add additional indexes as needed
