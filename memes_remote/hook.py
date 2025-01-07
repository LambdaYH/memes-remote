from typing import Dict, Any

from nonebot.matcher import current_event
from nonebot.adapters import Bot
from nonebot.adapters.onebot.v11 import Event
from nonebot.exception import MockApiException

@Bot.on_calling_api
async def _(
    bot: Bot,
    api: str,
    data: Dict[str, Any],
): 
    # 遍历上下文中的所有变量
    event: Event = current_event.get(None)
    if event is not None and isinstance(event, Event):
        data["__self_id__"] = event.self_id
    else:
        raise MockApiException(result={})