#let project(doc) = {
  let text_size = 14pt
  let gap = 3em
  let indent = 1.25cm
  let linespacing = 1.1em // Примерно соответствует полуторному интервалу
  
  // --- 1. ОБЩИЕ НАСТРОЙКИ ---
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 1cm, top: 2cm, bottom: 2cm),
  )
  
  set text(
    font: "Times New Roman",
    size: text_size,
    lang: "ru",
  )
  
  set par(
    first-line-indent: (amount: indent, all: true),
    justify: true,
    leading: linespacing, 
  )
  
  set block(spacing: gap)
  show outline: set block(spacing: linespacing)
  
  set math.equation(numbering: n => {
    "(" + str(n) + ")"
  }, supplement: none)
  show math.equation: it => {
    if it.block == false {
      it
    } else {
      pad(left: indent, align(left,it))
    }
  }
  
  set figure.caption(separator: [ -- ])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set align(left)
  show figure.where(kind: image): set figure(supplement: [Рисунок])

  // Изменение отображения ссылок (показывает только номер)
  show ref: it => {
    let el = it.element
    // Меняем правила только для figure
    if el != none and el.func() == figure {
      // Формируем ссылку заново: берем локацию и только цифру счетчика
      link(el.location(), numbering(el.numbering, ..counter(figure).at(el.location())))
    } else {
      // Для всего остальное ничего не меняем
      it
    }
  }
  
  show table.cell.where(y: 0): strong
  set table(
    row-gutter: (1pt, auto),
    stroke: 0.5pt
  )
  show table.cell: it => {
    let centered = if it.body.has("text") {
      it.body.text.trim().match(regex("^\d+([.,]\d+)?$")) != none
    } else {
      false
    }
    if it.y == 0 {
      centered = true
    }
    set align(if centered { center + horizon } else { left + horizon })
    it
  }
  
  set list(indent: indent, marker: "-")
  set enum(indent: indent, numbering: "a.1)")
  show list: set block(spacing: linespacing)
  show enum: set block(spacing: linespacing)
  show enum: it => {
    set enum(indent: 0pt)
    it
  }
  
  // --- 2. СТИЛИ ЗАГОЛОВКОВ ---
  // Настройка нумерации
  set heading(numbering: "1.1.1")
  show heading: it => {
    set text(size: text_size)
    set block(spacing: gap)
    if it.numbering == none {
      align(center, it)
    } else {
      pad(left: indent, it)
    }
  }
  doc
}