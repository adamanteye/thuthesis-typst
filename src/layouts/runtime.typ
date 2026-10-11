// The sole state boundary for a compiled thesis. Configuration is captured by
// instance closures and never stored globally.

#let thuthesis-runtime = {
  let _initial = (
    started: false,
    active: false,
    matter: "title",
    appendix: false,
    once: (),
    heading-kind: "body",
    heading-outline: auto,
    heading-header: auto,
    after-heading: none,
    achievements: 0,
  )

  let _runtime = state("thuthesis.runtime", _initial)

  let start() = {
    context {
      let current = _runtime.get()
      assert(
        not current.started and not current.active,
        message: "thuthesis: apply the thesis document layout only once",
      )
    }
    _runtime.update(_initial + (started: true, active: true))
  }

  let finish() = _runtime.update(current => current + (active: false))

  let require-active() = context assert(
    _runtime.get().active,
    message: "thuthesis: apply `#show: meta` before using a thesis page",
  )

  let transition(matter, appendix: false) = {
    require-active()
    _runtime.update(current => (
      current
        + (
          matter: matter,
          appendix: appendix,
          heading-kind: "body",
          heading-outline: auto,
          heading-header: auto,
          after-heading: none,
        )
    ))
  }

  let once(name, body) = {
    require-active()
    context assert(
      name not in _runtime.get().once,
      message: "thuthesis: `" + name + "` may only be generated once",
    )
    _runtime.update(current => current + (once: current.once + (name,)))
    body
  }

  let begin-special-heading(kind, outline-title, header) = _runtime.update(
    current => (
      current
        + (
          heading-kind: kind,
          heading-outline: outline-title,
          heading-header: header,
        )
    ),
  )

  let end-special-heading() = _runtime.update(current => (
    current
      + (
        heading-kind: "body",
        heading-outline: auto,
        heading-header: auto,
      )
  ))

  let mark-after-heading(kind, figure-correction: 0pt) = _runtime.update(
    current => (
      current
        + (
          after-heading: (
            kind: kind,
            figure-correction: figure-correction,
          ),
        )
    ),
  )

  let clear-after-heading() = _runtime.update(
    current => current + (after-heading: none),
  )

  let reset-achievements() = _runtime.update(
    current => current + (achievements: 0),
  )

  let achievements(count, render) = {
    require-active()
    context {
      let start = _runtime.get().achievements + 1
      _runtime.update(current => (
        current + (achievements: current.achievements + count)
      ))
      render(start)
    }
  }

  let appendix-at(location) = _runtime.at(location).appendix
  let matter-at(location) = _runtime.at(location).matter
  let heading-kind-at(location) = _runtime.at(location).heading-kind
  let heading-outline-at(location) = _runtime.at(location).heading-outline
  let heading-header-at(location) = _runtime.at(location).heading-header
  let after-heading-at(location) = _runtime.at(location).after-heading

  (
    start: start,
    finish: finish,
    require-active: require-active,
    transition: transition,
    once: once,
    begin-special-heading: begin-special-heading,
    end-special-heading: end-special-heading,
    mark-after-heading: mark-after-heading,
    clear-after-heading: clear-after-heading,
    reset-achievements: reset-achievements,
    achievements: achievements,
    appendix-at: appendix-at,
    matter-at: matter-at,
    heading-kind-at: heading-kind-at,
    heading-outline-at: heading-outline-at,
    heading-header-at: heading-header-at,
    after-heading-at: after-heading-at,
  )
}
