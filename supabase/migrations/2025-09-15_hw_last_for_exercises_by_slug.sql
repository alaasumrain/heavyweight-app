-- Create slug-based RPC to fetch latest set per exercise for current user
-- Accepts exercise slugs; maps to IDs server-side to avoid client warmup lookups
-- Returns latest set fields matching the ID-based RPC

CREATE OR REPLACE FUNCTION public.hw_last_for_exercises_by_slug(slugs text[])
RETURNS TABLE (
  exercise_slug text,
  weight numeric,
  actual_reps smallint,
  set_number int,
  rest_taken int,
  created_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH ex AS (
    SELECT e.id, lower(
      CASE 
        WHEN e.name = 'Bench Press' THEN 'bench'
        WHEN e.name = 'Squat' THEN 'squat'
        WHEN e.name = 'Deadlift' THEN 'deadlift'
        WHEN e.name = 'Overhead Press' THEN 'overhead'
        WHEN e.name = 'Row' THEN 'row'
        WHEN e.name = 'Pull-ups' THEN 'pullup'
        ELSE replace(lower(e.name), ' ', '_')
      END
    ) AS slug
    FROM public.exercises e
    WHERE lower(
      CASE 
        WHEN e.name = 'Bench Press' THEN 'bench'
        WHEN e.name = 'Squat' THEN 'squat'
        WHEN e.name = 'Deadlift' THEN 'deadlift'
        WHEN e.name = 'Overhead Press' THEN 'overhead'
        WHEN e.name = 'Row' THEN 'row'
        WHEN e.name = 'Pull-ups' THEN 'pullup'
        ELSE replace(lower(e.name), ' ', '_')
      END
    ) = ANY(slugs)
  )
  SELECT DISTINCT ON (s.exercise_id)
    ex.slug as exercise_slug,
    s.weight,
    s.actual_reps,
    COALESCE(s.set_number, 1) as set_number,
    COALESCE(s.rest_taken, 180) as rest_taken,
    s.created_at
  FROM public.sets s
  JOIN public.workouts w ON w.id = s.workout_id
  JOIN ex ON ex.id = s.exercise_id
  WHERE w.user_id = auth.uid()
    AND ex.slug = ANY(slugs)
  ORDER BY s.exercise_id, s.created_at DESC;
$$;

GRANT EXECUTE ON FUNCTION public.hw_last_for_exercises_by_slug(text[]) TO authenticated;

