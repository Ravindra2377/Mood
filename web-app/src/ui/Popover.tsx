import React from 'react'

// Simple Popover: expects two children — trigger and panel content.
// @ts-nocheck
export default function Popover(props: any) {
  const { children, id } = props
  const [open, setOpen] = React.useState(false)
  const rootRef = React.useRef<HTMLDivElement>(null)

  React.useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    function onDoc(e: any) {
      if (!rootRef.current) return
      if (rootRef.current.Implement the remaining screens (Activities, Journal, Meditation full UI) to match the design images.
Make the BottomNavigation responsive to the current route (highlight active item) by wiring into your existing navigation logic (App.tsx uses a custom navigate helper). I can adapt it to use that helper if you prefer not to use react-router for navigation.
Check the backend too(e.target)) return
      setOpen(false)
    }
    document.addEventListener('click', onDoc)
    return () => document.removeEventListener('click', onDoc)
  }, [])

  const parts = React.Children.toArray(children)
  const trigger = parts[0] || null
  const panel = parts[1] || null

  return (
    <div className="popover-root" ref={rootRef} aria-haspopup="dialog">
  {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
  <div onClick={() => setOpen((prev: any) => !prev)} aria-expanded={open} aria-controls={id}>{trigger}</div>
      <div id={id} role="dialog" className={`popover-panel ${open ? 'show' : ''}`} aria-hidden={!open}>
        <div className="popover-tip">
          {panel}
        </div>
      </div>
    </div>
  )
}
