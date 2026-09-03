import { useEffect, useState } from "react";
import type { Comment, User } from "../../api/types";
import { api } from "../../api/client";

interface CommentListProps {
  taskId: string;
  currentUser: User;
  refreshKey: number;
}

export default function CommentList({ taskId, currentUser, refreshKey }: CommentListProps) {
  const [comments, setComments] = useState<Comment[]>([]);

  useEffect(() => {
    api.getComments(taskId).then(setComments).catch(console.error);
  }, [taskId, refreshKey]);

  const handleDelete = async (id: string) => {
    await api.deleteComment(id, currentUser.id);
    setComments((prev) => prev.filter((c) => c.id !== id));
  };

  if (comments.length === 0) {
    return <p className="text-sm text-gray-400">No comments yet.</p>;
  }

  return (
    <ul className="mb-3 flex flex-col gap-3">
      {comments.map((comment) => (
        <li key={comment.id} className="rounded border border-gray-100 bg-gray-50 p-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-gray-700">{comment.author_name}</span>
            {comment.user_id === currentUser.id && (
              <button
                onClick={() => handleDelete(comment.id)}
                className="text-xs text-red-500 hover:underline"
              >
                Delete
              </button>
            )}
          </div>
          <p className="mt-1 text-sm text-gray-800">{comment.content}</p>
        </li>
      ))}
    </ul>
  );
}
