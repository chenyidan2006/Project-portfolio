/* Use original project images; no simulated App UI or fabricated signal graphics. */
const lightbox = document.querySelector('.lightbox');
const previewImage = lightbox.querySelector('img');
const previewCaption = lightbox.querySelector('.lightbox-caption');
let opener = null;

document.querySelectorAll('[data-lightbox]').forEach(button => {
  button.addEventListener('click', () => {
    const source = button.querySelector('img');
    if (!source) return;
    opener = button;
    previewImage.src = button.dataset.original || source.src;
    previewImage.alt = button.dataset.caption || source.alt;
    previewCaption.textContent = button.dataset.caption || source.alt;
    lightbox.showModal();
    document.body.classList.add('preview-open');
  });
});
lightbox.querySelector('.lightbox-close').addEventListener('click', () => lightbox.close());
lightbox.addEventListener('click', event => {
  if (event.target !== lightbox) return;
  const box = lightbox.getBoundingClientRect();
  if (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom) lightbox.close();
});
lightbox.addEventListener('close', () => {
  document.body.classList.remove('preview-open');
  if (opener) opener.focus({ preventScroll: true });
});
