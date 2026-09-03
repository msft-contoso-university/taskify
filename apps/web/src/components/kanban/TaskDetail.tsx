import { useEffect, useState } from "react";
import type { Task, User } from "../../api/types";
import { api } from "../../api/client";
import CommentList from "../comments/CommentList";
import CommentForm from "../comments/CommentForm";

interface TaskDetailProps {
  task: Task;
  currentUser: User;
  users: User[];
  onClose: () => void;
  onChanged: () => void;
}

export default function TaskDetail({ task, currentUser, users, onClose, onChanged }: TaskDetailProps) {
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    setRefreshKey((k) => k + 1);
  }, [task.id]);

  const handleAssign = async (userId: string) => {
    await api.assignTask(task.id, userId || null);
    onChanged();
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/40 p-4" onClick={onClose}>
      <div
        className="max-h-[80vh] w-full max-w-lg overflow-y-auto rounded-lg bg-white p-6 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mb-4 flex items-start justify-between">
          <h2 className="text-lg font-semibold text-gray-900">{task.title}</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ✕
          </button>
        </div>

        {task.description && <p className="mb-4 text-sm text-gray-600">{task.description}</p>}

        <div className="mb-4">
          <label className="mb-1 block text-xs font-medium text-gray-500">Assignee</label>
          <select
            value={task.assigned_user_id ?? ""}
            onChange={(e) => handleAssign(e.target.value)}
            className="w-full rounded border border-gray-300 p-2 text-sm"
          >
            <option value="">Unassigned</option>
            {users.map((u) => (
              <option key={u.id} value={u.id}>
                {u.name}
              </option>
            ))}
          </select>
        </div>

        <hr className="my-4" />

        <h3 className="mb-2 text-sm font-semibold text-gray-700">Comments</h3>
        <CommentList taskId={task.id} currentUser={currentUser} refreshKey={refreshKey} />
        <CommentForm
          taskId={task.id}
          currentUser={currentUser}
          onAdded={() => setRefreshKey((k) => k + 1)}
        />
      </div>
    </div>
  );
}
