{% if page.prev or page.next %}
  <nav class="pagination">
    {{
      paginator({
        prev_text: '🔙',
        next_text: '🔜',
        mid_size: 1
      })
    }}
  </nav>
{% endif %}
