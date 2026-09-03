import type { User } from "../../api/types";

interface UserSelectProps {
  users: User[];
  onSelect: (user: User) => void;
}

export default function UserSelect({ users, onSelect }: UserSelectProps) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-50 p-6">
      <h1 className="mb-6 text-2xl font-semibold text-gray-900">Who are you?</h1>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        {users.map((user) => (
          <button
            key={user.id}
            onClick={() => onSelect(user)}
            className="flex flex-col items-center gap-2 rounded-lg border border-gray-200 bg-white p-4 shadow-sm transition hover:shadow-md"
          >
            <span
              className="flex h-12 w-12 items-center justify-center rounded-full text-lg font-medium text-white"
              style={{ backgroundColor: user.avatar_color }}
            >
              {user.name.charAt(0)}
            </span>
            <span className="text-sm font-medium text-gray-800">{user.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
