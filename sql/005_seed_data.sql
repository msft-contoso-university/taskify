-- =============================================================================
-- Taskify Seed Data
-- =============================================================================
-- Seeds fixed-UUID demo data so re-running docker-compose (with a fresh
-- volume) is idempotent and deterministic for demos.
-- =============================================================================

INSERT INTO users (id, name, role, avatar_color) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'Ada Lovelace', 'admin', '#6366f1'),
    ('a2222222-2222-2222-2222-222222222222', 'Grace Hopper', 'member', '#22c55e'),
    ('a3333333-3333-3333-3333-333333333333', 'Alan Turing', 'member', '#f97316'),
    ('a4444444-4444-4444-4444-444444444444', 'Margaret Hamilton', 'member', '#ec4899')
ON CONFLICT (id) DO NOTHING;

INSERT INTO projects (id, name, description) VALUES
    ('b1111111-1111-1111-1111-111111111111', 'Taskify Launch', 'Ship the Taskify Kanban app end-to-end.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO tasks (id, project_id, title, description, status, position, assigned_user_id) VALUES
    ('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111',
     'Design database schema', 'Define users/projects/tasks/comments tables.', 'done', 0,
     'a1111111-1111-1111-1111-111111111111'),
    ('c2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111',
     'Build REST API', 'Implement Express routes for all resources.', 'in_progress', 0,
     'a2222222-2222-2222-2222-222222222222'),
    ('c3333333-3333-3333-3333-333333333333', 'b1111111-1111-1111-1111-111111111111',
     'Build Kanban board UI', 'React + drag-and-drop board with columns.', 'in_review', 0,
     'a3333333-3333-3333-3333-333333333333'),
    ('c4444444-4444-4444-4444-444444444444', 'b1111111-1111-1111-1111-111111111111',
     'Provision Azure infrastructure', 'Terraform for Container Apps, Postgres, networking.', 'todo', 0,
     NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO comments (id, task_id, user_id, parent_comment_id, content) VALUES
    ('d1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222',
     'a1111111-1111-1111-1111-111111111111', NULL, 'Let''s make sure we cover pagination for large projects.'),
    ('d2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222',
     'a2222222-2222-2222-2222-222222222222', 'd1111111-1111-1111-1111-111111111111', 'Good call, adding it to the API design.')
ON CONFLICT (id) DO NOTHING;
