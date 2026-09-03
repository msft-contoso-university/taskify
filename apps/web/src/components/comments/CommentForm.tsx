import { useState } from "react";
import type { User } from "../../api/types";
import { api } from "../../api/client";

interface CommentFormProps {
  taskId: string;
  currentUser: User;
  onAdded: () => void;
}

export default function CommentForm({ taskId, currentUser, onAdded }: CommentFormProps) {
  const [content, setContent] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;
    setSubmitting(true);
    try {
      await api.addComment(taskId, content.trim(), currentUser.id);
      setContent("");
      onAdded();
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <input
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Add a comment..."
        className="flex-1 rounded border border-gray-300 p-2 text-sm"
      />
      <button
        type="submit"
        disabled={submitting}
        className="rounded bg-indigo-600 px-3 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
      >
        Post
      </button>
    </form>
  );
}
