// Sizes used across the template.
#let script-size = 8pt
#let footnote-size = 8.5pt
#let small-size = 9pt
#let normal-size = 10pt
#let heading-size = 11pt
#let large-size = 12pt
#let very-large-size = 14pt

// This function gets your whole document as its `body` and formats
// it as an article in the style of the American Mathematical Society.
#let ams-article(
  // The article's title.
  title: [Paper title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The article's paper size. Also affects the margins.
  paper-size: "a4",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The document's content.
  body,
) = {
  // Formats the author's names in a list with commas and a
  // final "and".
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  // Set document metadata.
  set document(title: title, author: names)

  // Set the body font. AMS uses the LaTeX font.
  set text(size: normal-size, font: "New Computer Modern")

  // Configure the page.
  set page(
    paper: paper-size,
    margin: (
        top: 97pt,
        left: 80pt,
        right: 80pt,
        bottom: 76pt,
      ),

    header-ascent: 32pt,
    header: context {
      let h = query(selector(heading.where(level: 1)).before(here()))
      let h = if h.len() > 0 {
        h.last().body
      } else {
        []
      }
      //align(center, text(size: script-size, [#i]))
      // TODO fix header
      // let i = counter(page).get().first()
      // if i == 1 { return }
      // set text(size: script-size)
      align(center, h)
    },
    footer-descent: 36pt,
    footer: context {
      let i = counter(page).get().first()
      align(center, text(size: script-size, [#i]))
    }
  )

  // Configure headings.
  set heading(numbering: "1.")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    // Level 1 headings are centered and smallcaps.
    // The other ones are run-in.
    set text(size: normal-size, weight: 400)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set align(center)
      set text(size: very-large-size)
      smallcaps[
        #v(15pt, weak: true)
        #number
        #it.body
        #v(large-size, weak: true)
      ]
      counter(figure.where(kind: "theorem")).update(0)
    } else if it.level == 2 {
      v(17pt, weak: true)
      set align(center)
      set text(size: heading-size)
      strong(number + it.body)
      h(7pt, weak: true)
    } else if it.level == 3 {
      v(11pt, weak: true)
      set text(size: normal-size)
      strong(number + it.body)
      h(7pt, weak: true)
    } else {
      v(11pt, weak: true)
      number
      emph(it.body + [. ])
      h(7pt, weak: true)
    }
  }

  // Configure lists and links.
  set list(indent: 24pt, body-indent: 5pt)
  set enum(indent: 24pt, body-indent: 5pt)
  show link: set text(font: "New Computer Modern Mono")

  // Configure equations.
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)

  // Configure citation and bibliography styles.
  set std.bibliography(style: "institute-of-electrical-and-electronics-engineers", title: [References])

  set figure(gap: 17pt)
  show figure: set block(above: 12.5pt, below: 15pt)
  show figure: it => {
    // Customize the figure's caption.
    show figure.caption: caption => {
      smallcaps(caption.supplement)
      if caption.numbering != none {
        [ ]
        numbering(caption.numbering, ..caption.counter.at(it.location()))
      }
      [. ]
      caption.body
    }

    // We want a bit of space around tables and images.
    show selector.or(table, image): pad.with(x: 23pt)

    // Display the figure's body and caption.
    it
  }

  // Theorems.
  show figure.where(kind: "theorem"): set align(start)
  show figure.where(kind: "theorem"): it => block(spacing: 11.5pt, {
    strong({
      it.supplement
      if it.numbering != none {
        [ ]
        it.counter.display(it.numbering)
      }
      [.]
    })
    [ ]
    emph(it.body)
  })

  // Display the title and authors.
  v(35pt, weak: true)
  align(center, {
    text(size: large-size, weight: 700, title)
    v(25pt, weak: true)
    text(size: footnote-size, author-string)
  })

  // Configure paragraph properties.
  set par(spacing: 1em, first-line-indent: 1.2em, justify: true, leading: 1em)

  // Display the abstract
  if abstract != none {
    v(20pt, weak: true)
    set text(script-size)
    show: pad.with(x: 35pt)
    smallcaps[Abstract. ]
    abstract
  }

  // Display the article's contents.
  v(29pt, weak: true)
  body

  // Display the bibliography, if any is given.
  if bibliography != none {
    show std.bibliography: set text(footnote-size)
    show std.bibliography: set block(above: 11pt)
    show std.bibliography: pad.with(x: 0.5pt)
    bibliography
  }

  // Display details about the authors at the end.
  v(12pt, weak: true)
  show: pad.with(x: 11.5pt)
  set par(first-line-indent: 0pt)
  set text(script-size)

  for author in authors {
    let keys = ("department", "organization", "location")

    let dept-str = keys
      .filter(key => key in author)
      .map(key => author.at(key))
      .join(", ")

    smallcaps(dept-str)
    linebreak()

    if "email" in author [
      _Email address:_ #link("mailto:" + author.email) \
    ]

    if "url" in author [
      _URL:_ #link(author.url)
    ]

    v(12pt, weak: true)
  }
}

// // The ASM template also provides a theorem function.
// #let theorem(body, numbered: true) = figure(
//   body,
//   kind: "theorem",
//   supplement: [Theorem],
//   numbering: if numbered { n => counter(heading).display() + [#n] }
// )

// #let defn(body, numbered: true) = align(left)[#figure(
//   [

//     *Definition.*
//     #body
//   ],
//   placement: none,
//   kind: "definition",
//   supplement: [Definition],
//   numbering: if numbered { n => counter(heading).display() + [#n] }
// )]

// // And a function for a proof.
// #let proof(body) = block(spacing: 11.5pt, {
//   emph[Proof.]
//   [ ]
//   body
//   h(1fr)

//   // Add a word-joiner so that the proof square and the last word before the
//   // 1fr spacing are kept together.
//   sym.wj

//   // Add a non-breaking space to ensure a minimum amount of space between the
//   // text and the proof square.
//   sym.space.nobreak

//   $square.stroked$
// })