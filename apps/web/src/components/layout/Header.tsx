import type { User } from "../../api/types";

interface HeaderProps {
  currentUser: User;
  onSwitchUser: () => void;
}

export default function Header({ currentUser, onSwitchUser }: HeaderProps) {
  return (
    <header className="flex items-center justify-between bg-white px-6 py-4 shadow-sm">
      <h1 className="text-xl font-semibold text-gray-900">Taskify</h1>
      <div className="flex items-center gap-3">
        <span
          className="flex h-8 w-8 items-center justify-center rounded-full text-sm font-medium text-white"
          style={{ backgroundColor: currentUser.avatar_color }}
        >
          {currentUser.name.charAt(0)}
        </span>
        <span className="text-sm text-gray-700">{currentUser.name}</span>
        <button
          onClick={onSwitchUser}
          className="text-sm text-indigo-600 hover:underline"
        >
          Switch user
        </button>
      </div>
    </header>
  );
}
