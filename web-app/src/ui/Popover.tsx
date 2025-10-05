import React from 'react'

// Simple Popover: expects two children — trigger and panel content.
// @ts-nocheck
export default function Popover(props: any) {
  const { children, id } = props
  const [open, setOpen] = React.useState(false)
  const rootRef = React.useRef(null)

  React.useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    function onDoc(e: any) {
      if (!rootRef.current) return
      if (rootRef.current.contains(e.target)) return
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
