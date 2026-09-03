import type { Comment, Project, Task, User } from "./types";

const BASE = "/api";

async function request<T>(path: string, options: RequestInit = {}, userId?: string): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };
  if (userId) headers["X-User-Id"] = userId;

  const res = await fetch(`${BASE}${path}`, { ...options, headers });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message || `Request failed: ${res.status}`);
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  getUsers: () => request<User[]>("/users"),
  getProjects: () => request<Project[]>("/projects"),
  getProject: (id: string) => request<Project>(`/projects/${id}`),
  createProject: (name: string, description?: string) =>
    request<Project>("/projects", { method: "POST", body: JSON.stringify({ name, description }) }),

  getTasks: (projectId: string) => request<Task[]>(`/projects/${projectId}/tasks`),
  createTask: (projectId: string, title: string, description?: string) =>
    request<Task>(`/projects/${projectId}/tasks`, {
      method: "POST",
      body: JSON.stringify({ title, description }),
    }),
  updateTask: (id: string, title: string, description?: string) =>
    request<Task>(`/tasks/${id}`, { method: "PUT", body: JSON.stringify({ title, description }) }),
  updateTaskStatus: (id: string, status: string, position: number) =>
    request<Task>(`/tasks/${id}/status`, {
      method: "PATCH",
      body: JSON.stringify({ status, position }),
    }),
  assignTask: (id: string, assignedUserId: string | null) =>
    request<Task>(`/tasks/${id}/assign`, {
      method: "PATCH",
      body: JSON.stringify({ assigned_user_id: assignedUserId }),
    }),
  deleteTask: (id: string) => request<void>(`/tasks/${id}`, { method: "DELETE" }),

  getComments: (taskId: string) => request<Comment[]>(`/tasks/${taskId}/comments`),
  addComment: (taskId: string, content: string, userId: string, parentCommentId?: string) =>
    request<Comment>(
      `/tasks/${taskId}/comments`,
      { method: "POST", body: JSON.stringify({ content, parent_comment_id: parentCommentId }) },
      userId
    ),
  updateComment: (id: string, content: string, userId: string) =>
    request<Comment>(`/comments/${id}`, { method: "PUT", body: JSON.stringify({ content }) }, userId),
  deleteComment: (id: string, userId: string) =>
    request<void>(`/comments/${id}`, { method: "DELETE" }, userId),
};
