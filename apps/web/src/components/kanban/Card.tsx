import { Draggable } from "@hello-pangea/dnd";
import type { Task } from "../../api/types";

interface CardProps {
  task: Task;
  index: number;
  onClick: () => void;
}

export default function Card({ task, index, onClick }: CardProps) {
  return (
    <Draggable draggableId={task.id} index={index}>
      {(provided, snapshot) => (
        <div
          ref={provided.innerRef}
          {...provided.draggableProps}
          {...provided.dragHandleProps}
          onClick={onClick}
          className={`cursor-pointer rounded-md border border-gray-200 bg-white p-3 shadow-sm transition ${
            snapshot.isDragging ? "shadow-lg" : ""
          }`}
        >
          <p className="text-sm font-medium text-gray-900">{task.title}</p>
          {task.assigned_user_name && (
            <span
              className="mt-2 inline-flex h-6 w-6 items-center justify-center rounded-full text-xs font-medium text-white"
              style={{ backgroundColor: task.assigned_user_avatar_color ?? "#6366f1" }}
              title={task.assigned_user_name}
            >
              {task.assigned_user_name.charAt(0)}
            </span>
          )}
        </div>
      )}
    </Draggable>
  );
}
