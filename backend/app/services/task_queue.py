import threading
import time
import queue
import logging
from typing import Callable, Any
from app.config import settings

log = logging.getLogger('task_queue')


class TaskItem:
    def __init__(self, func: Callable, args: tuple = (), kwargs: dict = None, retries: int = 0):
        self.func = func
        self.args = args
        self.kwargs = kwargs or {}
        self.retries = retries


_queue = queue.Queue()


def enqueue(func: Callable, *args, **kwargs):
    item = TaskItem(func, args=args, kwargs=kwargs, retries=0)
    _queue.put(item)


def _worker_loop():
    while True:
        try:
            item: TaskItem = _queue.get()
            try:
                item.func(*item.args, **item.kwargs)
            except Exception as e:
                item.retries += 1
                log.exception('Task failed, retry %s', item.retries)
                if item.retries <= settings.BACKGROUND_TASK_MAX_RETRIES:
                    # simple backoff
                    time.sleep(1 * item.retries)
                    _queue.put(item)
                else:
                    log.error('Task permanently failed after retries')
            finally:
                _queue.task_done()
        except Exception:
            log.exception('Worker loop error')
        time.sleep(settings.BACKGROUND_WORKER_POLL_SECONDS)


_worker_thread = None


def start_worker():
    global _worker_thread
    if _worker_thread is not None:
        return
    _worker_thread = threading.Thread(target=_worker_loop, daemon=True)
    _worker_thread.start()


# start at import time if enabled
if settings.ENABLE_BACKGROUND_WORKER:
    start_worker()
