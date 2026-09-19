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

  // The article's paper size. Also affects the margins.
  paper-size: "a4",

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
  show math.equation: set text(font: "New Computer Modern Math")

  // Configure the page.
  set page(
    paper: paper-size,
    margin: (
        top: 97pt,
        left: 80pt,
        right: 80pt,
        bottom: 76pt,
      ),
    numbering: "i.",
    header-ascent: 32pt,
    header: context {
      let here-loc = here()
  
      // Find headings on the current page
      let page-headings = query(
        selector(heading.where(level: 1))
          .after(here-loc, inclusive: false)
      )
      
      // Check if there's a heading at the very start of this page
      let h = if page-headings.len() > 0 {
        // Get the first heading on this page
        let first-on-page = page-headings.first()
        
        // Check if it's at the top of the page (same page as header)
        if first-on-page.location().page() == here-loc.page() {
          []
        } else {
          // Fall back to the previous heading
          let prev = query(selector(heading.where(level: 1)).before(here-loc))
          if prev.len() > 0 { prev.last().body } else { [] }
        }
      } else {
        // No heading on this page, use the previous one
        let prev = query(selector(heading.where(level: 1)).before(here-loc))
        if prev.len() > 0 { prev.last().body } else { [] }
      }

      align(center, h)
    },
    footer-descent: 36pt,
    footer: {
      []
    }
  )

  // Configure headings.
  set heading(numbering: (..nums) => {
    nums.pos().map(str).join(".")
  })
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      [.]
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

  // Configure equations.
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)
  

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
  // v(35pt, weak: true)
  // align(center, {
  //   text(size: large-size, weight: 700, title)
  //   v(25pt, weak: true)
  //   text(size: footnote-size, author-string)
  // })


  

  


  [
    #set page(fill: cmyk(100%, 0%, 0%, 0%), margin: 0pt)
    #set par(spacing: 0em, first-line-indent: 0em, justify: false, leading: 0.5em)

    #place(top + left, dx: 60pt, dy: 100pt)[
      #set text(fill: white, size: 36pt)
      #[Proof Step Checking in a \ Constraint Programming \ Unsatisfiability Proof Checker \ ]
      #set par(spacing: 1em, leading: 1em)
      #set text(fill: white, size: 20pt)
      #[Tip ten Brink]
      #text(size: 36pt, fill: white, weight: 550, [
        
      ])
      #text(size: 20pt, fill: white, weight: "light", [
        
      ])
    ]

    #place(left + horizon, dx: 20pt, [
      #rotate(270deg, reflow: true)[
        #set text(fill: white, size: 14pt)
        Delft University of Technology
      ]
    ])
    
    #place(bottom + left, dx: 15pt, dy: 10pt, image("TUDelft_logo_white.svg", width: 30%))

    #pagebreak()
    
    #set page(fill: none)

    #v(80pt)
    #align(center)[
      #text(size: 32pt)[Proof Step Checking in a \ Constraint Programming \ Unsatisfiability Proof Checker ]
      #v(36pt)
      #text(size: 12pt)[by]
      #v(30pt)
      #text(size: 22pt)[Tip ten Brink]
      #v(24pt)
      #text(size: 12pt)[
        to obtain the degree of MSc Computer Science \
        at the Delft University of Technology, \
        to be defended publicly on Friday September 12th, 2025 at 14:00.
      ]
      #v(30em)
      #pad(x: 0pt,
        grid(
          columns: (1fr, 1fr),
          gutter: 20pt,
          align(left)[
            #pad(left: 20em)[
              Student number: \
              Project duration: \
              Thesis committee: \
            ]
            
          ],
          align(left)[
            4927192 \
            November 6, 2024 -- September 12, 2025 \
            Dr. E. Demirović, Supervisor \
            Dr. B. Ahrens \
          ]
        )
      )
    
    ]

    #place(bottom + center, dy: -80pt, image("TUDelft_logo_black.svg", width: 25%))

    
  ]
  
  // Configure paragraph properties.
  set par(spacing: 1em, first-line-indent: 1.2em, justify: true, leading: 1em)

  body

  
  
  
  // // Display details about the authors at the end.
  // v(12pt, weak: true)
  // show: pad.with(x: 11.5pt)
  // set par(first-line-indent: 0pt)
  // set text(script-size)

  // for author in authors {
  //   let keys = ("department", "organization", "location")

  //   let dept-str = keys
  //     .filter(key => key in author)
  //     .map(key => author.at(key))
  //     .join(", ")

  //   smallcaps(dept-str)
  //   linebreak()

  //   if "email" in author [
  //     _Email address:_ #link("mailto:" + author.email) \
  //   ]

  //   if "url" in author [
  //     _URL:_ #link(author.url)
  //   ]

  //   v(12pt, weak: true)
  // }
}

#let ams-biblio(bibliography: none) = {
  set std.bibliography(style: "ieee.csl", title: [References])

  // Display the bibliography, if any is given.
  if bibliography != none {
    show std.bibliography: set text(footnote-size)
    show std.bibliography: set block(above: 11pt)
    show std.bibliography: pad.with(x: 0.5pt)
    bibliography
  }

}