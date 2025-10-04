from fastapi import APIRouter, Depends, HTTPException
from app.dependencies import get_current_user
from app.schemas.community import GroupCreate, GroupRead, PostCreate, PostRead, CommentCreate, CommentRead, MemberInfo
from app.services.analytics import record_event

router = APIRouter()


@router.get('/groups', response_model=list[GroupRead])
def list_groups():
    from app.main import SessionLocal
    from app.models.community import CommunityGroup
    db = SessionLocal()
    try:
        return db.query(CommunityGroup).all()
    finally:
        db.close()


@router.post('/groups', response_model=GroupRead)
def create_group(payload: GroupCreate, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import CommunityGroup
    db = SessionLocal()
    try:
        existing = db.query(CommunityGroup).filter(CommunityGroup.key == payload.key).first()
        if existing:
            raise HTTPException(status_code=400, detail='Group key exists')
        g = CommunityGroup(key=payload.key, title=payload.title, description=payload.description, guidelines=payload.guidelines)
        db.add(g)
        db.commit()
        db.refresh(g)
        return g
    finally:
        db.close()


@router.post('/groups/{group_key}/join')
def join_group(group_key: str, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, GroupMembership
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')
        existing = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == g.id).first()
        if existing:
            return {'joined': True}
        gm = GroupMembership(user_id=current_user.id, group_id=g.id)
        db.add(gm)
        db.commit()
        return {'joined': True}
    finally:
        db.close()


@router.post('/posts', response_model=PostRead)
def create_post(payload: PostCreate, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, Post, GroupMembership
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == payload.group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')
        # ensure membership (auto-join)
        mem = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == g.id).first()
        if not mem:
            mem = GroupMembership(user_id=current_user.id, group_id=g.id)
            db.add(mem)
            db.commit()
        p = Post(group_id=g.id, user_id=current_user.id if not payload.anon else None, anon=1 if payload.anon else 0, title=payload.title, body=payload.body)
        db.add(p)
        db.commit()
        db.refresh(p)
        try:
            record_event('community.post', user_id=current_user.id, props={'group': g.key, 'post_id': p.id, 'anon': bool(payload.anon)})
        except Exception:
            pass
        return p
    finally:
        db.close()


@router.post('/comments', response_model=CommentRead)
def create_comment(payload: CommentCreate, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import Post, Comment
    db = SessionLocal()
    try:
        post = db.query(Post).filter(Post.id == payload.post_id).first()
        if not post:
            raise HTTPException(status_code=404, detail='Post not found')
        c = Comment(post_id=post.id, user_id=current_user.id if not payload.anon else None, anon=1 if payload.anon else 0, body=payload.body)
        db.add(c)
        db.commit()
        db.refresh(c)
        try:
            record_event('community.comment', user_id=current_user.id, props={'post_id': post.id, 'comment_id': c.id, 'anon': bool(payload.anon)})
        except Exception:
            pass
        return c
    finally:
        db.close()


@router.post('/posts/{post_id}/flag')
def flag_post(post_id: int, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import Post
    db = SessionLocal()
    try:
        p = db.query(Post).filter(Post.id == post_id).first()
        if not p:
            raise HTTPException(status_code=404, detail='Post not found')
        p.flagged = 1
        db.add(p)
        db.commit()
        try:
            record_event('community.post.flag', user_id=current_user.id, props={'post_id': p.id})
        except Exception:
            pass
        return {'flagged': True}
    finally:
        db.close()


@router.post('/comments/{comment_id}/flag')
def flag_comment(comment_id: int, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import Comment
    db = SessionLocal()
    try:
        c = db.query(Comment).filter(Comment.id == comment_id).first()
        if not c:
            raise HTTPException(status_code=404, detail='Comment not found')
        c.flagged = 1
        db.add(c)
        db.commit()
        try:
            record_event('community.comment.flag', user_id=current_user.id, props={'comment_id': c.id})
        except Exception:
            pass
        return {'flagged': True}
    finally:
        db.close()


@router.post('/moderation/posts/{post_id}/remove')
def remove_post(post_id: int, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import Post
    db = SessionLocal()
    try:
        # moderation: only allow moderators (in group) or admins
        p = db.query(Post).filter(Post.id == post_id).first()
        if not p:
            raise HTTPException(status_code=404, detail='Post not found')
        # check membership role
        from app.models.community import GroupMembership
        gm = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == p.group_id).first()
        if not gm and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')
        if gm and gm.role != 'moderator' and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')

        p.removed = 1
        db.add(p)
        db.commit()
        try:
            record_event('community.post.removed', user_id=current_user.id, props={'post_id': p.id})
        except Exception:
            pass
        return {'removed': True}
    finally:
        db.close()


@router.post('/groups/{group_key}/members/{member_user_id}/promote')
def promote_member(group_key: str, member_user_id: int, current_user = Depends(get_current_user)):
    """Promote a group member to moderator. Requester must be admin or existing moderator."""
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, GroupMembership
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')
        # check requester privileges
        requester_gm = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == g.id).first()
        if not requester_gm and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')
        if requester_gm and requester_gm.role != 'moderator' and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')

        mem = db.query(GroupMembership).filter(GroupMembership.user_id == member_user_id, GroupMembership.group_id == g.id).first()
        if not mem:
            raise HTTPException(status_code=404, detail='Membership not found')
        mem.role = 'moderator'
        db.add(mem)
        db.commit()
        return {'promoted': True}
    finally:
        db.close()


@router.post('/groups/{group_key}/members/{member_user_id}/demote')
def demote_member(group_key: str, member_user_id: int, current_user = Depends(get_current_user)):
    """Demote a moderator to member. Requester must be admin or existing moderator."""
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, GroupMembership
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')
        requester_gm = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == g.id).first()
        if not requester_gm and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')
        if requester_gm and requester_gm.role != 'moderator' and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')

        mem = db.query(GroupMembership).filter(GroupMembership.user_id == member_user_id, GroupMembership.group_id == g.id).first()
        if not mem:
            raise HTTPException(status_code=404, detail='Membership not found')
        mem.role = 'member'
        db.add(mem)
        db.commit()
        return {'demoted': True}
    finally:
        db.close()


@router.get('/groups/{group_key}/members', response_model=list[MemberInfo])
def list_members(group_key: str, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, GroupMembership
    from app.models.user import User
    from app.models.profile import Profile
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')

        # join memberships -> users -> profile to include email and display_name
        results = (
            db.query(
                GroupMembership.user_id,
                User.email,
                Profile.display_name,
                GroupMembership.role,
                GroupMembership.joined_at,
            )
            .join(User, GroupMembership.user_id == User.id)
            .outerjoin(Profile, Profile.user_id == User.id)
            .filter(GroupMembership.group_id == g.id)
            .all()
        )

        # import settings here so tests can reload app.config and change policy at runtime
        from app.config import settings as runtime_settings
        policy = (getattr(runtime_settings, 'COMMUNITY_MEMBER_EMAIL_POLICY', 'masked') or 'masked').lower()

        is_admin = getattr(current_user, 'role', 'user') == 'admin'

        def mask_email(email: str | None) -> str | None:
            if not email or '@' not in email:
                return email
            local, domain = email.split('@', 1)
            if len(local) <= 1:
                return f'*@{domain}'
            # preserve first char and mask the rest of local part
            return f"{local[0]}***@{domain}"

        members = []
        for r in results:
            # Determine email exposure based on policy
            if policy == 'full':
                email_value = r.email
            elif policy == 'hidden':
                email_value = r.email if is_admin else None
            else:  # masked default
                email_value = r.email if is_admin else mask_email(r.email)

            members.append({
                'user_id': r.user_id,
                'email': email_value,
                'display_name': r.display_name,
                'role': r.role,
                'joined_at': r.joined_at,
            })

        return members
    finally:
        db.close()


@router.delete('/groups/{group_key}/members/{member_user_id}')
def remove_member(group_key: str, member_user_id: int, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.community import CommunityGroup, GroupMembership
    db = SessionLocal()
    try:
        g = db.query(CommunityGroup).filter(CommunityGroup.key == group_key).first()
        if not g:
            raise HTTPException(status_code=404, detail='Group not found')
        # check privileges
        requester_gm = db.query(GroupMembership).filter(GroupMembership.user_id == current_user.id, GroupMembership.group_id == g.id).first()
        if not requester_gm and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')
        if requester_gm and requester_gm.role != 'moderator' and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')

        mem = db.query(GroupMembership).filter(GroupMembership.user_id == member_user_id, GroupMembership.group_id == g.id).first()
        if not mem:
            raise HTTPException(status_code=404, detail='Membership not found')
        db.delete(mem)
        db.commit()
        return {'removed': True}
    finally:
        db.close()
    