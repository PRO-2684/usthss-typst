#import "bilingual-bibliography.typ" : show-bibliography

#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 字体 = (
  仿宋: ("Times New Roman", "FangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
)

#let lengthceil(len, unit: 字号.小四) = calc.ceil(len / unit) * unit
#let partCounter = counter("part")
#let chapterCounter = counter("chapter")
#let appendixCounter = counter("appendix")
#let footnoteCounter = counter(footnote)
#let rawCounter = counter(figure.where(kind: "code"))
#let imageCounter = counter(figure.where(kind: image))
#let tableCounter = counter(figure.where(kind: table))
#let equationCounter = counter(math.equation)
#let appendix() = {
  appendixCounter.update(10)
  chapterCounter.update(0)
  counter(heading).update(0)
}
#let skippedState = state("skipped", false)
#let isCoverPage = state("iscover", true) // default true for first page header

#let chineseNumeral(num, standalone: false) = if num < 11 {
  ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十").at(num)
} else if num < 100 {
  if calc.rem(num, 10) == 0 {
    chineseNumeral(calc.floor(num / 10)) + "十"
  } else if num < 20 and standalone {
    "十" + chineseNumeral(calc.rem(num, 10))
  } else {
    chineseNumeral(calc.floor(num / 10)) + "十" + chineseNumeral(calc.rem(num, 10))
  }
} else if num < 1000 {
  let left = chineseNumeral(calc.floor(num / 100)) + "百"
  if calc.rem(num, 100) == 0 {
    left
  } else if calc.rem(num, 100) < 10 {
    left + "零" + chineseNumeral(calc.rem(num, 100))
  } else {
    left + chineseNumeral(calc.rem(num, 100))
  }
} else {
  let left = chineseNumeral(calc.floor(num / 1000)) + "千"
  if calc.rem(num, 1000) == 0 {
    left
  } else if calc.rem(num, 1000) < 10 {
    left + "零" + chineseNumeral(calc.rem(num, 1000))
  } else if calc.rem(num, 1000) < 100 {
    left + "零" + chineseNumeral(calc.rem(num, 1000))
  } else {
    left + chineseNumeral(calc.rem(num, 1000))
  }
}

#let chineseNumeralFormatting(..nums, location: none, brackets: false) = context{
  let loc = if location == none { here() } else { location }
  if appendixCounter.at(loc).first() < 10 {
    if nums.pos().len() == 1 {
      "第" + chineseNumeral(nums.pos().first(), standalone: true) + "章"
    } else {
      numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
}

#let chineseHeaderNumbering(..nums, location: none, brackets: false) = context{
  let loc = if location == none { here() } else { location }
  if appendixCounter.at(loc).first() < 10 {
    if nums.pos().len() == 1 {
      "第" + chineseNumeral(nums.pos().first(), standalone: true) + "章"
    } else if nums.pos().len() == 2 {
      "第" + chineseNumeral(nums.pos().last(), standalone: true) + "节"
    } else if nums.pos().len() == 3 {
      chineseNumeral(nums.pos().last(), standalone: true) + "、" + h(-1em)
    } else if nums.pos().len() == 4 {
      numbering({ "1." }, nums.pos().last())
    } else if nums.pos().len() == 5 {
      numbering({ "(1)" }, nums.pos().last())
    } else {
      // numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
}

#let chineseUnderline(s, width: 300pt, bold: false) = {
  let chars = s.clusters()
  let n = chars.len()
  style(styles => {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt, styles).width > width or c == "\n" {
        if bold {
          ret.push(strong(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%))
    }

    ret.join()
  })
}

#let chineseOutline(title: "目录", depth: none, indent: false) = {
  set text(size: 字号.小四, font: 字体.宋体)
  heading(title, numbering: none, outlined: false)
  context{
    let elements = query(heading.where(outlined: true).after(here()))

    for el in elements {
      // Skip list of images and list of tables
      if partCounter.at(el.location()).first() < 20 and el.numbering == none { continue }

      // Skip headings that are too deep
      if depth != none and el.level > depth { continue }

      let maybeNumber = if el.numbering != none {
        if el.numbering == chineseNumeralFormatting {
          chineseNumeralFormatting(..counter(heading).at(el.location()), location: el.location())
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
        h(0.5em)
      }

      let line = {
        if indent {
          h(1em * (el.level - 1 ))
        }

        if el.level == 1 {
          v(0.5em, weak: true)
        }

        if maybeNumber != none {
          context{
            let width = measure(maybeNumber).width
            box(
              width: lengthceil(width),
              link(el.location(), if el.level == 1 {
                strong(maybeNumber)
              } else {
                maybeNumber
              })
            )
          }
        }

        link(el.location(), if el.level == 1 {
          strong(el.body)
        } else {
          el.body
        })

        // Filler dots
        if el.level == 1 {
          box(width: 1fr, h(10pt) + box(width: 1fr) + h(10pt))
        } else {
          box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))
        }

        // Page number
        let footer = query(selector(<__footer__>).after(el.location()))
        let pageNumber = if footer == () {
          0
        } else {
          counter(page).at(footer.first().location()).first()
        }

        link(el.location(), if el.level == 1 {
          strong(str(pageNumber))
        } else {
          str(pageNumber)
        })

        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

#let listFigures(title: "插图", kind: image) = {
  heading(title, numbering: none, outlined: false)
  locate(it => {
    let elements = query(figure.where(kind: kind).after(it), it)

    for el in elements {
      let maybeNumber = {
        let loc = el.location()
        chineseNumeralFormatting(chapterCounter.at(loc).first(), counter(figure.where(kind: kind)).at(loc).first(), location: loc)
        h(0.5em)
      }
      let line = {
        style(styles => {
          let width = measure(maybeNumber, styles).width
          box(
            width: lengthceil(width),
            link(el.location(), maybeNumber)
          )
        })

        link(el.location(), el.caption.body)

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footers = query(selector(<__footer__>).after(el.location()), el.location())
        let pageNumber = if footers == () {
          0
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(), str(pageNumber))
        linebreak()
        v(-0.2em)
      }

      line
    }
  })
}

#let codeblock(raw, caption: none, outline: false) = {
  figure(
    if outline {
      rect(width: 100%)[
        #set align(left)
        #raw
      ]
    } else {
      set align(left)
      raw
    },
    caption: caption, kind: "code", supplement: ""
  )
}

#let booktab(columns: (), aligns: (), width: auto, caption: none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())
  set align(center)

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let contentAligns = ()
  for i in range(0, contents.len()) {
    contentAligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  return figure(
    block(
      width: width,
      grid(
        columns: (auto),
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..headers.zip(aligns).map(it => [
                #set align(it.last())
                #strong(it.first())
              ])
            )
          )
        ],
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..contents.zip(contentAligns).map(it => [
                #set align(it.last())
                #it.first()
              ])
            )
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table
  )
}

#let conf(
  authorCN: "张三",
  studentID: "PB2000xxxxx",
  thesisName: "本科毕业论文",
  thesisHeader: "中国科学技术大学本科毕业论文",
  thesisTitle: "中国科学技术大学\n学位论文 Typst 模板",
  major: "某个专业",
  supervisor: "李四",
  date: datetime.today().display("[year] 年 [month] 月 [day] 日"),
  abstractCN: [],
  keywordsCN: (),
  abstractEN: [],
  keywordsEN: (),
  acknowledgements: [],
  lineSpacing: 10pt,
  outlineDepth: 3,
  listImages: false,
  listTables: false,
  listCodes: false,
  alwaysStartOdd: false,
  doc,
) = {
  let smartPageBreak = () => {
    if alwaysStartOdd {
      skippedState.update(true)
      pagebreak(to: "odd", weak: true)
      skippedState.update(false)
    } else {
      pagebreak(weak: true)
    }
  }

  set page("a4",
    header: context{
      if isCoverPage.at(here()) {
        // skip cover
        return
      }
      [
        #set text(size: 字号.小五, font: 字体.宋体)
        #set align(center)
        #thesisHeader
        #v(-1em) // ??
        // #v(-linespacing)
        #line(length: 100%)
      ]
    },
    footer: context{
      if skippedState.at(here()) and calc.even(here().page()) { return }
      [
        #set text(font: 字体.宋体, size: 字号.小五)
        #set align(center)
        #if query(selector(heading).before(here())).len() < 3 or query(selector(heading).after(here())).len() == 0 {
          // Skip cover, copyright and origin pages
          // skip cabstract & eabstract
        } else {
          let headers = query(selector(heading).before(here()))
          let part = partCounter.at(headers.last().location()).first()
          [
            #str(counter(page).at(here()).first())
          ]
        }
        #label("__footer__")
      ]
    },
  )

  set text(字号.一号, font: 字体.宋体, lang: "zh")
  set align(center + horizon)
  set heading(numbering: chineseHeaderNumbering)
  set figure(
    numbering: (..nums) => context{
      if appendixCounter.at(here()).first() < 10 {
        numbering("1.1", chapterCounter.at(here()).first(), ..nums)
      } else {
        numbering("A.1", chapterCounter.at(here()).first(), ..nums)
      }
    }
  )
  // set table style
  set table(
    stroke: (x, y) => if x >= 0 and y == 0 {
      (top: (
        paint: black,
        thickness: 2pt,
        dash: "solid"
        ),
      left: 1pt + black,
      right: 1pt + black,
      bottom: 1pt + black
      )
    } else {
      1pt + black
    }
  )
  set math.equation(
    numbering: (..nums) => context{
      set text(font: 字体.宋体)
      if appendixCounter.at(here()).first() < 10 {
        numbering("(1.1)", chapterCounter.at(here()).first(), ..nums)
      } else {
        numbering("(A.1)", chapterCounter.at(here()).first(), ..nums)
      }
    }
  )
  set list(indent: 2em)
  set enum(indent: 2em)

  show strong: it => text(font: 字体.黑体, weight: "semibold", it.body)
  show emph: it => text(font: 字体.楷体, style: "italic", it.body)
  show raw: set text(font: 字体.代码)

  show heading: it => [
    // Cancel indentation for headings
    #set par(first-line-indent: 0em)

    #let sizedheading(it, size) = [
      #set text(size)
      #v(2em)
      #if it.numbering != none {
        strong(counter(heading).display())
        h(0.5em)
      }
      #strong(it.body)
      #v(1em)
    ]

    #if it.level == 1 {
      if not it.body.text in ("Abstract", "学位论文使用授权说明", "版权声明")  {
        smartPageBreak()
      }
      context{
        if it.body.text == "摘要" {
          partCounter.update(10)
          counter(page).update(1)
        } else if it.numbering != none and partCounter.at(here()).first() < 20 {
          partCounter.update(20)
          // counter(page).update(1)
        } else if it.body.text == "目录" {
          // partcounter.update(20)
          counter(page).update(1)
        }
      }
      if it.numbering != none {
        chapterCounter.step()
      }
      footnoteCounter.update(())
      imageCounter.update(())
      tableCounter.update(())
      rawCounter.update(())
      equationCounter.update(())

      set align(center)
      if it.body.text in ("Abstract", "摘要", "目录") {
        sizedheading(it, 字号.小二)
      } else {
        sizedheading(it, 字号.三号)
      }
    } else {
      if it.level == 2 {
        set align(center)
        sizedheading(it, 字号.小三)
      } else if it.level == 3 {
        sizedheading(it, 字号.四号)
      } else {
        sizedheading(it, 字号.小四)
      }
    }
  ]

  show figure: it => [
    #set align(center)
    #if not it.has("kind") {
      it
    } else if it.kind == image {
      it.body
      [
        #set text(字号.五号)
        #it.caption
      ]
    } else if it.kind == table {
      [
        #set text(字号.五号)
        #it.caption
      ]
      it.body
    } else if it.kind == "code" {
      [
        #set text(字号.五号)
        代码#it.caption
      ]
      it.body
    }
  ]

  show ref: it => {
    if it.element == none {
      // Keep citations as is
      it
    } else {
      // Remove prefix spacing
      h(0em, weak: true)

      let el = it.element
      let el_loc = el.location()
      if el.func() == math.equation {
        // Handle equations
        link(el_loc, [
          式
          #chineseNumeralFormatting(chapterCounter.at(el_loc).first(), equationCounter.at(el_loc).first(), location: el_loc, brackets: true)
        ])
      } else if el.func() == figure {
        // Handle figures
        if el.kind == image {
          link(el_loc, [
            图
            #chineseNumeralFormatting(chapterCounter.at(el_loc).first(), imageCounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == table {
          link(el_loc, [
            表
            #chineseNumeralFormatting(chapterCounter.at(el_loc).first(), tableCounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == "code" {
          link(el_loc, [
            代码
            #chineseNumeralFormatting(chapterCounter.at(el_loc).first(), rawCounter.at(el_loc).first(), location: el_loc)
          ])
        }
      } else if el.func() == heading {
        // Handle headings
        if el.level == 1 {
          link(el_loc, chineseNumeralFormatting(..counter(heading).at(el_loc), location: el_loc))
        } else {
          link(el_loc, [
            节
            #chineseNumeralFormatting(..counter(heading).at(el_loc), location: el_loc)
          ])
        }
      }

      // Remove suffix spacing
      h(0em, weak: true)
    }
  }

  show: show-bibliography.with(bilingual: true)

  let fieldname(name) = [
    #set align(right + top)
    #strong(name)
  ]

  let fieldvalue(value) = [
    #set align(center + horizon)
    #set text(font: 字体.黑体, size: 字号.三号)
    #grid(
      rows: (auto, auto),
      row-gutter: 0.2em,
      value,
      line(length: 100%)
    )
  ]

  // Cover page

  {
    box(
      grid(
        columns: (auto, auto),
        gutter: 0.4em,
        image("./images/ustc-name-stxingkai.svg", height: 1.4em, fit: "contain"),
      )
    )
    linebreak()
    [
      #set text(font: 字体.黑体, size: 56pt, weight: "regular")
      #thesisName
    ]
    linebreak()
    v(1em)

    box(
      grid(
        columns: (auto, auto),
        gutter: 0.4em,
        image("ustclogo.svg", height: 4em, fit: "contain"),
      )
    )

    set text(字号.一号)
    // v(60pt)
    grid(
      columns: (0pt, 350pt),
      [
        #set align(right + top)
      ],
      [
        #set align(center + horizon)
        #strong(thesisTitle)
      ],
    )

    v(60pt)
    set text(字号.三号)

    grid(
      columns: (80pt, 280pt),
      row-gutter: 1em,
      fieldname("作者姓名："),
      fieldvalue(authorCN),
      fieldname(text("学") + h(2em) + text("号：")),
      fieldvalue(studentID),
      fieldname(text("专") + h(2em) + text("业：")),
      fieldvalue(major),
      fieldname("导师姓名："),
      fieldvalue(supervisor),
      fieldname("完成时间："),
      fieldvalue(date),
    )
  }

  isCoverPage.update(false) // before pagebreak(header generated);
  smartPageBreak()

  set align(left + top)
  // Chinese abstract
  par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
    #set text(font: 字体.宋体, size: 字号.小四)
    #heading(numbering: none, outlined: false, "摘要")
    #abstractCN
    #v(3em)
    #set par(first-line-indent: 0em)
    *关键词：*
    #keywordsCN.join("；")
    #v(2em)
  ]

  smartPageBreak()

  // English abstract
  par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
    #set text(size: 字号.小四)
    #heading(numbering: none, outlined: false, "Abstract")
    #abstractEN
    #v(3em)
    #set par(first-line-indent: 0em)
    *Key Words:*
    #h(0.5em, weak: true)
    #keywordsEN.join("; ")
    #v(2em)
  ]

  // Table of contents
  chineseOutline(
    title: "目录",
    depth: outlineDepth,
    indent: true,
  )

  if listImages {
    listFigures()
  }

  if listTables {
    listFigures(title: "表格", kind: table)
  }

  if listCodes {
    listFigures(title: "代码", kind: "code")
  }

  set text(font: 字体.宋体, size: 字号.小四)
  par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
    #doc
  ]

  {
    par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
      #heading(numbering: none, "致谢")
      #acknowledgements
    ]
  }
}
